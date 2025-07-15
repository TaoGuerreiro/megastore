# 🧪 Guide de Test des Scripts Instagram

Ce guide explique comment tester les scripts Python Instagram dans votre environnement Rails.

## 📋 Vue d'ensemble

Les tests sont organisés en plusieurs niveaux :

1. **Tests RSpec** - Tests unitaires des services Rails
2. **Tests Python** - Tests natifs des modules Python
3. **Tests d'intégration** - Tests Python-Rails combinés
4. **Tests manuels** - Tests interactifs

## 🚀 Démarrage Rapide

### 1. Vérifier l'environnement

```bash
# Vérifier que Python est disponible
rake instagram:check_python

# Installer les dépendances Python si nécessaire
rake instagram:install_python
```

### 2. Lancer tous les tests

```bash
# Tests complets (RSpec + Python)
rake instagram:test

# Tests RSpec uniquement
rake instagram:test_rspec

# Tests Python uniquement
rake instagram:test_python

# Tests d'intégration
rake instagram:test_integration
```

### 3. Test rapide

```bash
# Test rapide d'un script
rake instagram:quick_test
```

## 🧪 Tests RSpec

### Structure des tests

```
spec/services/instagram/
├── base_service_spec.rb
├── challenge_configurable_spec.rb
├── engagement_service_spec.rb
├── fetch_messages_service_spec.rb
├── fetch_user_id_service_spec.rb
├── send_message_service_spec.rb
├── integration_spec.rb
└── python_scripts_integration_spec.rb
```

### Exécution

```bash
# Tous les tests Instagram
bundle exec rspec spec/services/instagram/

# Test spécifique
bundle exec rspec spec/services/instagram/base_service_spec.rb

# Avec couverture
COVERAGE=true bundle exec rspec spec/services/instagram/
```

### Mocks et Stubs

Les tests utilisent des mocks pour éviter les appels réels à Instagram :

```ruby
# Mock d'un script Python
allow(Instagram::BaseService).to receive(:execute_script)
  .and_return({ "success" => true })

# Mock des credentials
allow(Rails.application).to receive(:credentials)
  .and_return(double(instagram: double(two_captcha_api_key: "test")))
```

## 🐍 Tests Python

### Structure des tests

```
app/instagram_scripts/tests/
└── test_scripts.py
```

### Exécution

```bash
# Depuis Rails
rake instagram:test_python

# Directement
cd app/instagram_scripts
python tests/test_scripts.py
```

### Tests disponibles

- **ConfigLoader** - Configuration et validation
- **ErrorHandler** - Gestion d'erreurs
- **InstagramClient** - Client Instagram (avec mocks)
- **HashtagService** - Service hashtags
- **UserService** - Service utilisateurs
- **MessageService** - Service messages
- **ScriptsIntegration** - Structure et dépendances

## 🔗 Tests d'Intégration

### Tests Python-Rails

```bash
bundle exec rspec spec/services/instagram/python_scripts_integration_spec.rb
```

Ces tests :
- Vérifient que les scripts Python sont exécutables
- Testent l'intégration avec les services Rails
- Valident la structure des réponses JSON
- Mesurent les performances

### Exemple de test

```ruby
it "récupère l'ID d'un utilisateur avec des données de test" do
  config_file = create_test_config_file(test_username, test_password)

  begin
    result = execute_python_script("fetch_user_id.py", config_file.path, "instagram")

    expect(result).to include("user_id")
    expect(result["user_id"]).to be_present
  ensure
    File.delete(config_file.path)
  end
end
```

## 🎯 Tests Manuels

### Script de test interactif

```bash
cd app/instagram_scripts
python test_manual.py
```

Ce script permet de :
- Tester chaque script individuellement
- Utiliser des credentials réels ou de test
- Voir les sorties en temps réel
- Vérifier l'environnement

### Menu interactif

```
🧪 Test Manuel des Scripts Instagram
==================================================

📋 Menu:
1. Vérifier l'environnement
2. Test fetch_user_id.py
3. Test search_hashtags.py
4. Test send_message.py
5. Test fetch_messages.py
6. Test fetch_followers.py
7. Test like_posts.py
8. Test engagement.py
9. Quitter
```

## 📊 Couverture de Code

### Générer un rapport

```bash
rake instagram:coverage
```

### Interpréter les résultats

- **RSpec** : Utilise SimpleCov pour la couverture Ruby
- **Python** : Les tests couvrent les modules principaux
- **Intégration** : Valide les interactions Python-Rails

## 🔧 Configuration des Tests

### Variables d'environnement

```bash
# Pour les tests
RAILS_ENV=test
COVERAGE=true  # Active SimpleCov

# Pour les tests Python
PYTHONPATH=app/instagram_scripts
```

### Fichiers de configuration

```ruby
# spec/support/instagram_test_helpers.rb
module InstagramTestHelpers
  def mock_instagram_credentials
    # Configuration des mocks
  end

  def create_instagram_test_data
    # Création de données de test
  end
end
```

## 🚨 Gestion des Erreurs

### Erreurs courantes

1. **Python non disponible**
   ```bash
   rake instagram:install_python
   ```

2. **Dépendances manquantes**
   ```bash
   pip install instagrapi requests 2captcha-python
   ```

3. **Scripts non exécutables**
   ```bash
   chmod +x app/instagram_scripts/scripts/*.py
   ```

4. **Timeout des tests**
   - Augmenter le timeout dans les tests
   - Vérifier la connexion réseau

### Debugging

```bash
# Mode verbose
bundle exec rspec spec/services/instagram/ --format documentation

# Debug Python
python -v app/instagram_scripts/tests/test_scripts.py

# Logs détaillés
RAILS_LOG_LEVEL=debug bundle exec rspec
```

## 📈 Tests de Performance

### Mesures incluses

- Temps d'exécution des scripts
- Utilisation mémoire
- Timeout automatique (60s par défaut)
- Validation des réponses JSON

### Exemple

```ruby
it "mesure le temps d'exécution des scripts" do
  start_time = Time.current

  execute_python_script("fetch_user_id.py", config_file.path, "instagram")

  execution_time = Time.current - start_time
  expect(execution_time).to be < 30.seconds
end
```

## 🔄 Intégration CI/CD

### GitHub Actions

```yaml
- name: Test Instagram Scripts
  run: |
    rake instagram:check_python
    rake instagram:test_rspec
    rake instagram:test_python
```

### Variables d'environnement CI

```yaml
env:
  RAILS_ENV: test
  COVERAGE: true
  PYTHONPATH: app/instagram_scripts
```

## 📝 Bonnes Pratiques

### Pour les développeurs

1. **Toujours mocker les appels Instagram** dans les tests RSpec
2. **Utiliser des données de test** pour les tests Python
3. **Nettoyer les fichiers temporaires** après les tests
4. **Valider les réponses JSON** des scripts Python
5. **Tester les cas d'erreur** en plus des cas de succès

### Pour les tests manuels

1. **Utiliser des comptes de test** pour éviter les limitations
2. **Respecter les limites Instagram** (rate limiting)
3. **Tester avec des données réalistes**
4. **Documenter les cas d'erreur** rencontrés

## 🆘 Support

### Logs utiles

```bash
# Logs Rails
tail -f log/test.log

# Logs Python
tail -f app/instagram_scripts/logs/*.json

# Logs d'exécution
tail -f app/instagram_scripts/stats/*.jsonl
```

### Commandes de diagnostic

```bash
# Vérifier l'environnement
rake instagram:check_python

# Test rapide
rake instagram:quick_test

# Test manuel
cd app/instagram_scripts && python test_manual.py
```

---

**Note** : Ces tests sont conçus pour éviter les appels réels à Instagram tout en validant le bon fonctionnement des scripts. Pour les tests en production, utilisez des comptes de test dédiés.
