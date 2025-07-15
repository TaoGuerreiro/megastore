# 🧪 Guide de Test Instagram - Script Unifié

## 🚀 Utilisation Rapide

### Configuration Initiale
```bash
# Configuration automatique de l'environnement
bin/setup_instagram_tests

# Ou configuration forcée
bin/setup_instagram_tests --force
```

### Test Complet (Recommandé)
```bash
# Lancer tous les tests Instagram (RSpec + Python + Intégration)
bin/test_instagram
```

### Tests Spécifiques
```bash
# Tests RSpec uniquement
bin/test_instagram --rspec-only

# Tests Python uniquement
bin/test_instagram --python-only

# Tests d'intégration uniquement
bin/test_instagram --integration-only
```

### Options Avancées
```bash
# Mode verbeux (affiche les commandes exécutées)
bin/test_instagram -v

# Format de sortie personnalisé
bin/test_instagram -f progress

# Ignorer certains types de tests
bin/test_instagram --skip-python
bin/test_instagram --skip-integration

# Afficher l'aide
bin/test_instagram -h
```

## 📋 Types de Tests

### 1. **Tests RSpec** (`--rspec-only`)
- Services Instagram Rails (`BaseService`, `EngagementService`, etc.)
- Modèles (`SocialCampagne`, `SocialTarget`)
- Validations et associations
- Logique métier

### 2. **Tests Python** (`--python-only`)
- Modules Python natifs
- Scripts Instagram individuels
- Gestion des erreurs
- Configuration et authentification

### 3. **Tests d'Intégration** (`--integration-only`)
- Interaction Rails ↔ Python
- Exécution de scripts depuis Rails
- Gestion des fichiers temporaires
- Flux de données complets

## 🎯 Exemples d'Utilisation

### Développement Quotidien
```bash
# Test rapide avant commit
bin/test_instagram --rspec-only

# Test complet avant déploiement
bin/test_instagram -v
```

### Debugging
```bash
# Tester uniquement les scripts Python
bin/test_instagram --python-only -v

# Tester l'intégration avec mode verbeux
bin/test_instagram --integration-only -v
```

### CI/CD
```bash
# Format JSON pour l'intégration continue
bin/test_instagram -f json
```

## 📊 Interprétation des Résultats

### Sortie Standard
```
🧪 Lancement des tests Instagram...
==================================================

📋 Tests RSpec...
------------------------------
[Sortie RSpec...]

🐍 Tests Python...
------------------------------
[Sortie Python...]

🔗 Tests d'intégration...
------------------------------
[Sortie Intégration...]

==================================================
📊 RÉSUMÉ DES TESTS
==================================================
✅ RSpec
✅ Python
✅ Intégration

📈 Statistiques:
   Total: 3
   Réussis: 3
   Échoués: 0

✅ Tous les tests sont passés avec succès!
```

### Codes de Sortie
- `0` : Tous les tests réussis
- `1` : Au moins un test a échoué

## 🔧 Configuration

### Configuration Automatique
Le script `bin/setup_instagram_tests` configure automatiquement :
- **Environnement virtuel Python** avec toutes les dépendances
- **Permissions des scripts** Python
- **Configuration RSpec** avec shoulda-matchers
- **Scripts de test** unifiés

### Environnement Python
Le script détecte automatiquement l'environnement Python :
- **Production** : `python3`
- **Développement** : `venv/bin/python` (si disponible)
- **Fallback** : `python3`

### Fichiers de Test
Le script cherche automatiquement les fichiers de test :
- RSpec : `spec/services/instagram/`, `spec/models/social_*.rb`
- Python : `app/instagram_scripts/tests/test_scripts.py`
- Intégration : `spec/services/instagram/python_scripts_integration_spec.rb`

## 🚨 Dépannage

### Erreur "Fichier non trouvé"
```bash
# Vérifier que les fichiers de test existent
ls spec/services/instagram/
ls app/instagram_scripts/tests/
```

### Erreur Python
```bash
# Vérifier l'environnement Python
python3 --version
ls app/instagram_scripts/venv/bin/python
```

### Erreur RSpec
```bash
# Vérifier les gems
bundle install
bundle exec rspec --version
```

## 🔄 Intégration avec Git Hooks

### Pre-commit Hook
```bash
# .git/hooks/pre-commit
#!/bin/sh
bin/test_instagram --rspec-only || exit 1
```

### Pre-push Hook
```bash
# .git/hooks/pre-push
#!/bin/sh
bin/test_instagram || exit 1
```

## 📈 Métriques et Rapports

### Format JSON
```bash
bin/test_instagram -f json > test_results.json
```

### Intégration CI/CD
```bash
# GitHub Actions, GitLab CI, etc.
- name: Test Instagram
  run: bin/test_instagram -f json
```

## 🎯 Bonnes Pratiques

1. **Développement** : Utilisez `--rspec-only` pour les tests rapides
2. **Intégration** : Utilisez `-v` pour le debugging
3. **CI/CD** : Utilisez `-f json` pour les rapports automatisés
4. **Déploiement** : Lancez toujours le test complet avant déploiement

## 🔗 Liens Utiles

- [Documentation RSpec](https://rspec.info/)
- [Guide de Test Python](app/instagram_scripts/TESTING.md)
- [Services Instagram](app/services/instagram/)
- [Scripts Python](app/instagram_scripts/scripts/)

---

**Note** : Ce script remplace les anciennes commandes `rake instagram:*` et offre une interface unifiée pour tous les tests Instagram.
