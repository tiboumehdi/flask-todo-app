# Guide des Branch Protection Rules

Ce document explique comment nous utilisons les règles de protection des branches dans notre projet Flask Todo App pour maintenir un code de haute qualité et assurer une collaboration efficace.

## Configuration des règles de protection

Nous avons configuré les règles de protection suivantes sur notre branche principale (`main`) :

1. **Pull Requests obligatoires** : Toutes les modifications doivent être soumises via des Pull Requests.
2. **Approbations requises** : Chaque PR doit être approuvée par au moins un reviewer avant d'être mergée.
3. **Rejets des approbations obsolètes** : Les nouvelles modifications annulent les approbations précédentes.
4. **Revue par les propriétaires du code** : Certains fichiers nécessitent l'approbation de propriétaires spécifiques.
5. **Tests obligatoires** : Les tests automatisés doivent passer avec succès avant le merge.
6. **Branche à jour** : La branche de la PR doit être à jour avec la branche principale avant le merge.
7. **Restrictions de bypass** : Ces règles ne peuvent pas être contournées, même par les administrateurs.

## Workflow de développement

### Pour les contributeurs

1. **Travaillez toujours sur une branche dédiée** :
   ```bash
   git checkout -b feature/ma-fonctionnalite
   ```

2. **Poussez régulièrement vos changements** :
   ```bash
   git push origin feature/ma-fonctionnalite
   ```

3. **Restez à jour avec la branche principale** :
   ```bash
   git checkout main
   git pull
   git checkout feature/ma-fonctionnalite
   git merge main
   ```

4. **Créez une Pull Request** lorsque votre fonctionnalité est prête.

5. **Répondez aux commentaires** de la revue de code et apportez les modifications nécessaires.

### Pour les reviewers

1. **Examinez attentivement le code** :
   - Vérifiez la qualité du code (lisibilité, maintenabilité)
   - Assurez-vous que le code répond aux exigences fonctionnelles
   - Vérifiez la présence de tests appropriés
   - Identifiez les problèmes potentiels de sécurité ou de performance

2. **Fournissez des commentaires constructifs** :
   - Soyez spécifique et clair dans vos commentaires
   - Expliquez pourquoi un changement est nécessaire
   - Proposez des solutions alternatives si possible

3. **Approuvez ou demandez des modifications** selon votre évaluation.

### Pour les mainteneurs

1. **Mergez les PRs approuvées** en utilisant la méthode appropriée :
   - Merge commit : pour conserver l'historique complet
   - Squash and merge : pour consolider plusieurs commits en un seul
   - Rebase and merge : pour maintenir un historique linéaire

2. **Assurez la maintenance des branches** :
   - Supprimez les branches obsolètes après le merge
   - Surveillez les conflits potentiels entre les PRs

## Bonnes pratiques

- **Commits atomiques** : Faites des commits petits et ciblés qui adressent une seule préoccupation
- **Messages de commit clairs** : Utilisez des messages descriptifs qui expliquent le pourquoi, pas seulement le quoi
- **Documentation à jour** : Mettez à jour la documentation en même temps que le code
- **Tests automatisés** : Ajoutez des tests pour toutes les nouvelles fonctionnalités
- **Revues rapides** : Effectuez les revues de code dans un délai raisonnable

## Résolution des problèmes

Si vous rencontrez des difficultés avec les règles de protection des branches, contactez l'administrateur du dépôt ou référez-vous à la [documentation GitHub](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches).