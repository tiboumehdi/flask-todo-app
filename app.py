from flask import Flask, render_template, request, redirect, url_for, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os
import logging
import logging.handlers
import socket
import platform
import time
import json
import sys
import traceback
from prometheus_client import Counter, Histogram, Gauge, Info, generate_latest, CONTENT_TYPE_LATEST, CollectorRegistry, multiprocess, start_http_server

# Configuration du registry Prometheus pour mode multiprocess (si utilisé avec gunicorn)
if os.environ.get('PROMETHEUS_MULTIPROC_DIR'):
    multiprocess.MultiProcessCollector(CollectorRegistry())

# Initialisation des métriques Prometheus
REQUEST_COUNT = Counter('flask_http_requests_total', 'Total number of HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('flask_http_request_duration_seconds', 'HTTP request latency in seconds', ['method', 'endpoint'])
TASKS_COUNT = Gauge('flask_todo_tasks_total', 'Total number of tasks', ['status'])
DB_ERRORS = Counter('flask_todo_database_errors_total', 'Total number of database errors')
APP_INFO = Info('flask_todo_app_info', 'Application information')

# Configuration du logging
class JsonFormatter(logging.Formatter):
    def format(self, record):
        log_record = {
            "timestamp": self.formatTime(record, self.datefmt),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
            "host": socket.gethostname(),
            "application": "flask-todo"
        }
        
        if record.exc_info:
            log_record["exception"] = {
                "type": str(record.exc_info[0].__name__),
                "message": str(record.exc_info[1]),
                "traceback": traceback.format_exception(*record.exc_info)
            }
        
        return json.dumps(log_record)

def setup_logging():
    log_level_name = os.environ.get('LOG_LEVEL', 'INFO')
    log_level = getattr(logging, log_level_name.upper(), logging.INFO)
    
    # Configurer le logger racine
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)
    
    # Créer un handler pour stdout
    stdout_handler = logging.StreamHandler(sys.stdout)
    stdout_handler.setFormatter(JsonFormatter())
    root_logger.addHandler(stdout_handler)
    
    # Si LOG_FILE est défini, ajouter un FileHandler
    log_file = os.environ.get('LOG_FILE')
    if log_file:
        log_dir = os.path.dirname(log_file)
        if log_dir and not os.path.exists(log_dir):
            os.makedirs(log_dir)
        file_handler = logging.handlers.RotatingFileHandler(
            log_file, maxBytes=10485760, backupCount=5
        )
        file_handler.setFormatter(JsonFormatter())
        root_logger.addHandler(file_handler)
    
    # Désactiver les logs de Werkzeug en mode production
    if os.environ.get('FLASK_ENV') == 'production':
        logging.getLogger('werkzeug').setLevel(logging.ERROR)
    
    return logging.getLogger('flask-todo')

logger = setup_logging()

# Configuration de l'application Flask
app = Flask(__name__)

# Enregistrer les informations sur l'application
APP_INFO.info({
    'version': os.environ.get('APP_VERSION', 'dev'),
    'environment': os.environ.get('FLASK_ENV', 'development'),
    'python_version': platform.python_version(),
    'hostname': socket.gethostname()
})

# Configuration de la base de données depuis les variables d'environnement
db_uri = os.environ.get('SQLALCHEMY_DATABASE_URI', 'sqlite:///todo.db')
app.config['SQLALCHEMY_DATABASE_URI'] = db_uri
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.environ.get('FLASK_SECRET_KEY', 'dev-key-please-change-in-production')

# Middleware pour mesurer les temps de réponse
@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    request_latency = time.time() - request.start_time
    endpoint = request.endpoint if request.endpoint else 'unknown'
    REQUEST_COUNT.labels(request.method, endpoint, response.status_code).inc()
    REQUEST_LATENCY.labels(request.method, endpoint).observe(request_latency)
    
    # Ajouter des en-têtes de sécurité
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    
    # Logging des requêtes
    log_data = {
        'method': request.method,
        'path': request.path,
        'status': response.status_code,
        'duration_ms': round(request_latency * 1000, 2),
        'ip': request.remote_addr,
        'user_agent': request.user_agent.string
    }
    logger.info(f"Request processed: {json.dumps(log_data)}")
    
    return response

# Gestionnaire d'erreurs pour les exceptions non gérées
@app.errorhandler(Exception)
def handle_exception(e):
    logger.exception(f"Unhandled exception: {str(e)}")
    return jsonify(error="Internal Server Error"), 500

# Initialisation de la base de données
db = SQLAlchemy(app)

class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.String(200), nullable=False)
    completed = db.Column(db.Boolean, default=False)
    date_created = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<Task {self.id}>'

    def to_dict(self):
        return {
            'id': self.id,
            'content': self.content,
            'completed': self.completed,
            'date_created': self.date_created.isoformat()
        }

# Création des tables au démarrage
with app.app_context():
    try:
        db.create_all()
        logger.info("Base de donnees initialisee avec succes")
    except Exception as e:
        logger.error(f"Erreur lors de l'initialisation de la base de donnees: {str(e)}")
        DB_ERRORS.inc()

# Mise à jour des métriques de tâches
def update_task_metrics():
    with app.app_context():
        try:
            total_tasks = Todo.query.count()
            completed_tasks = Todo.query.filter_by(completed=True).count()
            pending_tasks = total_tasks - completed_tasks
            
            TASKS_COUNT.labels('total').set(total_tasks)
            TASKS_COUNT.labels('completed').set(completed_tasks)
            TASKS_COUNT.labels('pending').set(pending_tasks)
            
            logger.debug(f"Metrics updated: total={total_tasks}, completed={completed_tasks}, pending={pending_tasks}")
        except Exception as e:
            logger.error(f"Erreur lors de la mise a jour des metriques: {str(e)}")
            DB_ERRORS.inc()

@app.route('/', methods=['POST', 'GET'])
def index():
    if request.method == 'POST':
        task_content = request.form['content']
        if task_content.strip():
            new_task = Todo(content=task_content)
            try:
                db.session.add(new_task)
                db.session.commit()
                logger.info(f"Nouvelle tache creee: {task_content}")
                update_task_metrics()
                return redirect('/')
            except Exception as e:
                logger.error(f"Erreur lors de l'ajout de la tache: {str(e)}")
                DB_ERRORS.inc()
                return 'Une erreur est survenue lors de l\'ajout de votre tache'
        else:
            return redirect('/')

    else:
        try:
            tasks = Todo.query.order_by(Todo.date_created.desc()).all()
            return render_template('index.html', tasks=tasks)
        except Exception as e:
            logger.error(f"Erreur lors de la recuperation des taches: {str(e)}")
            DB_ERRORS.inc()
            return 'Une erreur est survenue lors de la recuperation des taches'

@app.route('/delete/<int:id>')
def delete(id):
    task_to_delete = Todo.query.get_or_404(id)

    try:
        db.session.delete(task_to_delete)
        db.session.commit()
        logger.info(f"Tache supprimee: ID {id}")
        update_task_metrics()
        return redirect('/')
    except Exception as e:
        logger.error(f"Erreur lors de la suppression de la tache {id}: {str(e)}")
        DB_ERRORS.inc()
        return 'Une erreur est survenue lors de la suppression de cette tache'

@app.route('/complete/<int:id>')
def complete(id):
    task = Todo.query.get_or_404(id)
    task.completed = not task.completed

    try:
        db.session.commit()
        status = "terminee" if task.completed else "non terminee"
        logger.info(f"Tache {id} marquee comme {status}")
        update_task_metrics()
        return redirect('/')
    except Exception as e:
        logger.error(f"Erreur lors de la mise a jour du statut de la tache {id}: {str(e)}")
        DB_ERRORS.inc()
        return 'Une erreur est survenue lors de la mise a jour de cette tache'

@app.route('/update/<int:id>', methods=['GET', 'POST'])
def update(id):
    task = Todo.query.get_or_404(id)

    if request.method == 'POST':
        task.content = request.form['content']

        try:
            db.session.commit()
            logger.info(f"Tache {id} mise a jour")
            return redirect('/')
        except Exception as e:
            logger.error(f"Erreur lors de la mise a jour de la tache {id}: {str(e)}")
            DB_ERRORS.inc()
            return 'Une erreur est survenue lors de la mise a jour de cette tache'

    else:
        return render_template('update.html', task=task)

# Endpoint pour healthcheck standard
@app.route('/health')
def health():
    # Basic health check
    health_data = {
        'status': 'ok',
        'timestamp': datetime.utcnow().isoformat(),
        'version': os.environ.get('APP_VERSION', 'dev'),
        'environment': os.environ.get('FLASK_ENV', 'development')
    }
    
    # Vérifier si la base de données est accessible
    try:
        db.session.execute('SELECT 1')
        health_data['database'] = 'ok'
    except Exception as e:
        logger.error(f"La base de donnees n'est pas accessible: {str(e)}")
        health_data['status'] = 'degraded'
        health_data['database'] = 'error'
        return jsonify(health_data), 500
    
    return jsonify(health_data)

# Endpoint pour healthcheck détaillé
@app.route('/health/details')
def health_details():
    health_data = {
        'status': 'ok',
        'timestamp': datetime.utcnow().isoformat(),
        'version': os.environ.get('APP_VERSION', 'dev'),
        'environment': os.environ.get('FLASK_ENV', 'development'),
        'python_version': platform.python_version(),
        'components': {
            'database': {
                'status': 'ok',
                'type': db.engine.name,
                'uri': db_uri.replace('://', '://****:****@') if '://' in db_uri else db_uri
            },
            'filesystem': {
                'status': 'ok',
                'writable': os.access('.', os.W_OK)
            }
        },
        'metrics': {
            'tasks_total': int(TASKS_COUNT.labels('total')._value.get()),
            'tasks_completed': int(TASKS_COUNT.labels('completed')._value.get()),
            'tasks_pending': int(TASKS_COUNT.labels('pending')._value.get()),
            'db_errors': int(DB_ERRORS._value.get())
        }
    }
    
    # Vérifier si la base de données est accessible
    try:
        db.session.execute('SELECT 1')
    except Exception as e:
        health_data['status'] = 'degraded'
        health_data['components']['database']['status'] = 'error'
        health_data['components']['database']['error'] = str(e)
    
    # Vérifier l'espace disque restant
    try:
        import shutil
        total, used, free = shutil.disk_usage('/')
        health_data['components']['disk'] = {
            'status': 'ok' if free / total > 0.1 else 'warning',
            'total_gb': round(total / (1024**3), 2),
            'used_gb': round(used / (1024**3), 2),
            'free_gb': round(free / (1024**3), 2),
            'free_percent': round((free / total) * 100, 2)
        }
    except Exception as e:
        health_data['components']['disk'] = {
            'status': 'unknown',
            'error': str(e)
        }
    
    # Status global basé sur tous les composants
    if any(component['status'] == 'error' for component in health_data['components'].values()):
        health_data['status'] = 'degraded'
        return jsonify(health_data), 500
    
    return jsonify(health_data)

# Exposer les métriques Prometheus
@app.route('/metrics')
def metrics():
    update_task_metrics()
    registry = CollectorRegistry()
    multiprocess.MultiProcessCollector(registry)
    return generate_latest(registry), 200, {'Content-Type': CONTENT_TYPE_LATEST}

# API pour les tâches (optionnel, pour l'intégration avec d'autres services)
@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    try:
        tasks = Todo.query.order_by(Todo.date_created.desc()).all()
        return jsonify([task.to_dict() for task in tasks])
    except Exception as e:
        logger.error(f"API - Erreur lors de la recuperation des taches: {str(e)}")
        DB_ERRORS.inc()
        return jsonify({"error": "Impossible de recuperer les taches"}), 500

if __name__ == "__main__":
    # Configuration du port depuis les variables d'environnement
    port = int(os.environ.get('PORT', 5000))
    
    # En mode production, on utilise 0.0.0.0 pour être accessible depuis l'extérieur
    host = '0.0.0.0' if os.environ.get('FLASK_ENV') == 'production' else '127.0.0.1'
    
    # Démarrer le serveur de métriques Prometheus s'il est configuré
    metrics_port = os.environ.get('METRICS_PORT')
    if metrics_port:
        start_http_server(int(metrics_port))
        logger.info(f"Serveur de metriques Prometheus demarre sur le port {metrics_port}")
    
    logger.info(f"Application Flask Todo demarree sur {host}:{port} en mode {os.environ.get('FLASK_ENV', 'development')}")
    app.run(host=host, port=port, debug=os.environ.get('FLASK_ENV') != 'production')