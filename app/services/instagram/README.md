# Services Instagram Refactorisés

Ce répertoire contient les services Rails pour l'intégration Instagram, refactorisés pour utiliser la nouvelle architecture des scripts Python.

## 🏗️ Nouvelle Architecture

### Structure des Services

```
app/services/instagram/
├── base_service.rb              # Service de base avec utilitaires communs
├── fetch_user_id_service.rb     # Service pour récupérer l'ID d'un utilisateur
├── fetch_messages_service.rb    # Service pour récupérer les messages
├── send_message_service.rb      # Service pour envoyer des messages
├── engagement_service.rb        # Service pour l'engagement automatisé
├── compatibility.rb             # Classes de compatibilité avec l'ancienne API
├── test_compatibility.rb        # Tests de compatibilité
└── README.md                    # Ce fichier
```

## 🔄 Migration Terminée

### ✅ **Refactorisation Complète**

Tous les services ont été refactorisés et les anciens services supprimés :

```ruby
# Nouveaux services (utilisés directement)
Instagram::FetchUserIdService.call(username: "user", password: "pass", handle: "handle")
Instagram::FetchMessagesService.call(username: "user", password: "pass", recipient_id: "123", hours_back: 24)
Instagram::SendMessageService.call(username: "user", password: "pass", recipient_id: "123", message: "Hello")
Instagram::EngagementService.call_from_user(user, username, password)
```

### 🗑️ **Anciens Services Supprimés**

Les anciens services suivants ont été supprimés :
- `Instagram::FetchUserId`
- `Instagram::FetchMessages`
- `Instagram::SendMessage`
- `Instagram::EngagementController`

## 📋 Services Disponibles

### 1. BaseService

Service de base avec utilitaires communs :

- **Gestion des scripts Python** : Exécution sécurisée des scripts
- **Validation des credentials** : Vérification des paramètres
- **Gestion d'erreurs** : Parsing et gestion des erreurs JSON
- **Logging** : Traçabilité complète des opérations

### 2. FetchUserIdService

Récupère l'ID d'un utilisateur Instagram à partir de son handle.

```ruby
user_id = Instagram::FetchUserIdService.call(
  username: "your_username",
  password: "your_password",
  handle: "target_user"
)
```

### 3. FetchMessagesService

Récupère les messages Instagram d'une conversation.

```ruby
messages = Instagram::FetchMessagesService.call(
  username: "your_username",
  password: "your_password",
  recipient_id: "123456789",
  hours_back: 24
)
```

### 4. SendMessageService

Envoie un message privé Instagram.

```ruby
result = Instagram::SendMessageService.call(
  username: "your_username",
  password: "your_password",
  recipient_id: "123456789",
  message: "Bonjour !"
)
```

### 5. EngagementService

Gère l'engagement automatisé (likes, follows, etc.).

```ruby
# Avec configuration manuelle
result = Instagram::EngagementService.call([
  {
    "username" => "your_username",
    "password" => "your_password",
    "hashtags" => [{"hashtag" => "fashion", "cursor" => nil}],
    "targeted_accounts" => [{"account" => "target_user", "cursor" => nil}]
  }
])

# Avec SocialTargets
result = Instagram::EngagementService.call_from_user(
  user,
  user.instagram_username,
  user.instagram_password,
  social_campagne: campaign
)
```

## 🔧 Améliorations

### 1. **Gestion d'Erreurs Améliorée**

```ruby
begin
  result = Instagram::FetchMessagesService.call(...)
rescue ArgumentError => e
  # Erreur de validation des paramètres
  Rails.logger.error("Paramètres invalides: #{e.message}")
rescue => e
  # Erreur d'exécution du script
  Rails.logger.error("Erreur Instagram: #{e.message}")
end
```

### 2. **Validation des Paramètres**

Tous les services valident automatiquement :
- Présence des credentials
- Format des user_id
- Plages de valeurs (ex: hours_back entre 0 et 8760)

### 3. **Logging Détaillé**

```ruby
# Les services loggent automatiquement :
Rails.logger.info("Instagram::FetchMessagesService: Exécution de fetch_messages.py avec args: [...]")
Rails.logger.error("Instagram::FetchMessagesService: Erreur lors de l'exécution de fetch_messages.py: ...")
```

### 4. **Gestion des Scripts Python**

- **Vérification d'existence** : Les services vérifient que les scripts existent
- **Exécution sécurisée** : Utilisation d'Open3 pour l'exécution
- **Parsing JSON** : Gestion robuste des réponses JSON
- **Gestion des erreurs** : Capture et traitement des erreurs Python

## 🧪 Tests de Compatibilité

Pour vérifier que tout fonctionne correctement :

```ruby
# Dans la console Rails
Instagram::TestCompatibility.run_tests
```

Cela vérifie :
- ✅ Existence des nouveaux services
- ✅ Compatibilité des méthodes
- ✅ Présence des scripts Python
- ✅ Migration terminée

## 📊 Jobs Compatibles

Tous les jobs existants continuent de fonctionner :

### FetchInstagramMessagesJob

```ruby
# Continue de fonctionner sans modification
FetchInstagramMessagesJob.perform_later(user_id, hours_back, recipient_id)
```

### SendInstagramMessageJob

```ruby
# Continue de fonctionner sans modification
SendInstagramMessageJob.perform_later(booking_message_id)
```

### InstagramEngagementJob

```ruby
# Continue de fonctionner sans modification
InstagramEngagementJob.perform_later(user_id, social_campagne_id)
```

### InstagramUserIdJob

```ruby
# Continue de fonctionner sans modification
InstagramUserIdJob.perform_async(model_name, record_id, ig_username, ig_password, ig_handle)
```

## 🔄 Migration Terminée

### ✅ **Migration Automatique Effectuée**

Tous les appels dans le code ont été automatiquement mis à jour :

- `app/jobs/instagram_user_id_job.rb` ✅
- `app/jobs/fetch_instagram_messages_job.rb` ✅
- `app/jobs/send_instagram_message_job.rb` ✅
- `app/jobs/instagram_engagement_job.rb` ✅

### 🎯 **Résultat**

La migration est terminée ! Tous les services utilisent maintenant directement les nouveaux services refactorisés.

## 🛡️ Sécurité

### Validation des Entrées

- **Credentials** : Vérification de la présence et du format
- **User IDs** : Validation du format numérique
- **Messages** : Vérification de la présence du contenu
- **Paramètres** : Validation des plages de valeurs

### Gestion des Erreurs

- **Erreurs Python** : Capture et logging des erreurs de scripts
- **Erreurs JSON** : Gestion robuste du parsing des réponses
- **Erreurs réseau** : Timeout et retry automatiques

### Logging Sécurisé

- **Pas de credentials** dans les logs
- **Traçabilité** complète des opérations
- **Erreurs détaillées** pour le debugging

## 📈 Avantages

1. **Compatibilité Totale** : Aucune modification des jobs existants
2. **Meilleure Gestion d'Erreurs** : Validation et logging améliorés
3. **Architecture Modulaire** : Services spécialisés et réutilisables
4. **Maintenabilité** : Code plus clair et mieux structuré
5. **Extensibilité** : Facile d'ajouter de nouveaux services
6. **Sécurité** : Validation et logging sécurisés

## 🚀 Utilisation

### Dans les Controllers

```ruby
class InstagramController < ApplicationController
  def fetch_user_id
    user_id = Instagram::FetchUserIdService.call(
      username: params[:username],
      password: params[:password],
      handle: params[:handle]
    )
    render json: { user_id: user_id }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
```

### Dans les Jobs

```ruby
class MyInstagramJob < ApplicationJob
  def perform(user_id)
    user = User.find(user_id)

    messages = Instagram::FetchMessagesService.call(
      username: user.instagram_username,
      password: user.instagram_password,
      recipient_id: "123456789",
      hours_back: 24
    )

    # Traitement des messages...
  end
end
```

### Dans les Services

```ruby
class MyService
  def self.process_instagram_data(user)
    result = Instagram::EngagementService.call_from_user(
      user,
      user.instagram_username,
      user.instagram_password
    )

    # Traitement du résultat...
  end
end
```

## 📝 Notes Importantes

1. **Migration Terminée** : Tous les services ont été refactorisés
2. **Compatibilité Assurée** : Tous les jobs existants continuent de fonctionner
3. **Amélioration Complète** : Nouveaux services avec meilleure gestion d'erreurs
4. **Architecture Modulaire** : Services spécialisés et réutilisables

## 🔍 Debugging

### Logs Rails

```ruby
# Activer les logs détaillés
Rails.logger.level = Logger::DEBUG
```

### Test de Compatibilité

```ruby
# Vérifier que tout fonctionne
Instagram::TestCompatibility.run_tests
```

### Test d'un Service

```ruby
# Tester un service spécifique
begin
  result = Instagram::FetchUserIdService.call(username: "test", password: "test", handle: "test")
  puts "✅ Service fonctionne"
rescue => e
  puts "❌ Erreur: #{e.message}"
end
```
