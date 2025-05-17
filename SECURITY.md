# Politique de Sécurité

## Signalement des Vulnérabilités

Si vous découvrez une vulnérabilité de sécurité dans ce projet, veuillez nous en informer en utilisant l'une des méthodes suivantes :

1. **Issues GitHub Privées** : Utilisez la fonctionnalité de signalement de vulnérabilité de GitHub dans l'onglet "Security" du dépôt.
2. **Email** : Envoyez un email à [mehditibou@gmail.com](mehditibou@gmail.com) avec le préfixe "[SÉCURITÉ]" dans le sujet.

Veuillez inclure les informations suivantes dans votre rapport :

- Type de vulnérabilité
- Chemin d'accès complet ou URL du fichier concerné
- Conditions requises pour reproduire la vulnérabilité
- Étapes pour reproduire le problème
- Impact potentiel de l'exploitation
- Suggestions pour résoudre ou atténuer la vulnérabilité (si possible)

## Politique de Divulgation

Nous adhérons à une politique de divulgation responsable :

1. Une fois votre rapport reçu, nous confirmerons la réception dans un délai de 48 heures.
2. Nous évaluerons la vulnérabilité et vous tiendrons informé des progrès.
3. Nous déterminerons un plan d'action et une date pour la publication du correctif.
4. Une fois le correctif prêt, nous le déploierons et vous informerons.
5. Nous vous créditerons publiquement (sauf si vous préférez rester anonyme) pour la découverte après la publication du correctif.

## Portée

Cette politique de sécurité couvre toutes les vulnérabilités dans :

- Le code source de l'application Flask Todo
- Les dépendances directes du projet
- La configuration Docker
- Les workflows CI/CD

## Niveau de Sévérité

Nous classons les vulnérabilités selon les niveaux de sévérité suivants :

- **Critique** : Vulnérabilités permettant une exécution de code à distance, un accès non autorisé aux données sensibles, ou une compromission complète du système.
- **Élevé** : Vulnérabilités pouvant entraîner une compromission partielle, une divulgation d'informations sensibles, ou un contournement de l'authentification.
- **Moyen** : Problèmes pouvant affecter l'intégrité des données ou la disponibilité, mais sans divulgation d'informations sensibles.
- **Faible** : Problèmes mineurs avec un impact limité sur la sécurité de l'application.

## Délais de Réponse

Nous nous efforçons de respecter les délais suivants :

- **Confirmation de réception** : 48 heures
- **Évaluation initiale** : 5 jours ouvrables
- **Correctif pour les vulnérabilités critiques** : 7 jours ouvrables
- **Correctif pour les vulnérabilités élevées** : 14 jours ouvrables
- **Correctif pour les vulnérabilités moyennes** : 30 jours ouvrables
- **Correctif pour les vulnérabilités faibles** : 60 jours ouvrables

## Programme de Reconnaissance

Bien que nous ne proposions pas de programme de récompense (bug bounty), nous reconnaissons publiquement les contributeurs qui signalent des vulnérabilités de manière responsable, sauf si vous préférez rester anonyme.

## Dernière Mise à Jour

Cette politique de sécurité a été mise à jour pour la dernière fois le 14 mai 2025.