# Scripts Instagram Refactorisés

Ce répertoire contient une version refactorisée et unifiée des scripts Instagram pour l'application Megastore.

## 🏗️ Architecture

### Structure des modules

```
instagram_scripts/
├── core/                    # Modules de base
│   ├── __init__.py
│   ├── client.py           # Client Instagram unifié
│   └── logger.py           # Système de logging
├── services/               # Services spécialisés
│   ├── __init__.py
│   ├── hashtag_service.py  # Gestion des hashtags
│   ├── user_service.py     # Gestion des utilisateurs
│   └── message_service.py  # Gestion des messages
├── scripts/                # Scripts d'exécution
│   ├── __init__.py
│   ├── search_hashtags.py
│   ├── fetch_followers.py
│   ├── fetch_messages.py
│   ├── send_message.py
│   ├── like_posts.py
│   └── fetch_user_id.py
└── README.md
```

## 🚀 Utilisation

### Prérequis

- Python 3.8+
- Bibliothèque `instagrapi`
- Compte Instagram valide

### Installation des dépendances

```bash
pip install instagrapi
```

### Scripts disponibles

#### 1. Recherche de hashtags

```bash
python scripts/search_hashtags.py <username> <password> <hashtag_name> [options]
```

**Options :**
- `--action`: Type d'action (`info`, `recent`, `top`, `recent_a1`, `top_a1`, `related`)
- `--amount`: Nombre de posts à récupérer (défaut: 20)
- `--cursor`: Curseur pour la pagination
- `--log-dir`: Répertoire de logs (défaut: logs)

**Exemples :**
```bash
# Informations sur un hashtag
python scripts/search_hashtags.py username password fashion --action info

# Posts récents d'un hashtag
python scripts/search_hashtags.py username password fashion --action recent --amount 50

# Posts populaires avec pagination
python scripts/search_hashtags.py username password fashion --action top --cursor "ABC123"
```

#### 2. Récupération des followers

```bash
python scripts/fetch_followers.py <username> <password> <target_username> [options]
```

**Options :**
- `--limit`: Nombre de followers à récupérer
- `--offset`: Offset pour la pagination (défaut: 0)
- `--cursor`: Curseur pour la pagination
- `--log-dir`: Répertoire de logs (défaut: logs)

**Exemples :**
```bash
# Récupérer 100 followers
python scripts/fetch_followers.py username password target_user --limit 100

# Récupérer avec offset et curseur
python scripts/fetch_followers.py username password target_user --limit 50 --offset 100 --cursor "XYZ789"
```

#### 3. Récupération des messages

```bash
python scripts/fetch_messages.py <username> <password> <recipient_id> [options]
```

**Options :**
- `--hours-back`: Nombre d'heures en arrière (défaut: 24)
- `--log-dir`: Répertoire de logs (défaut: logs)

**Exemples :**
```bash
# Messages des dernières 24h
python scripts/fetch_messages.py username password 123456789

# Messages des dernières 2h
python scripts/fetch_messages.py username password 123456789 --hours-back 2
```

#### 4. Envoi de messages

```bash
python scripts/send_message.py <username> <password> <recipient_id> <message> [options]
```

**Options :**
- `--log-dir`: Répertoire de logs (défaut: logs)

**Exemples :**
```bash
python scripts/send_message.py username password 123456789 "Bonjour !"
```

#### 5. Like de posts

```bash
python scripts/like_posts.py <username> <password> --mode <mode> --target <target> [options]
```

**Modes disponibles :**
- `user`: Liker des posts d'un utilisateur
- `hashtag`: Liker des posts d'un hashtag
- `random`: Liker des posts aléatoirement

**Options :**
- `--count`: Nombre de posts à liker (défaut: 5)
- `--hashtag-action`: Action pour les hashtags (`recent`, `top`, défaut: `recent`)
- `--cursor`: Curseur pour la pagination
- `--log-dir`: Répertoire de logs (défaut: logs)

**Exemples :**
```bash
# Liker des posts d'un utilisateur
python scripts/like_posts.py username password --mode user --target target_user --count 3

# Liker des posts d'un hashtag
python scripts/like_posts.py username password --mode hashtag --target fashion --count 5 --hashtag-action recent

# Liker des posts aléatoirement (user_id)
python scripts/like_posts.py username password --mode random --target 123456789 --count 2

# Liker des posts aléatoirement (media_ids)
python scripts/like_posts.py username password --mode random --target '["media1", "media2"]' --count 2
```

#### 6. Récupération d'ID utilisateur

```bash
python scripts/fetch_user_id.py <username> <password> <handle> [options]
```

**Options :**
- `--log-dir`: Répertoire de logs (défaut: logs)

**Exemples :**
```bash
python scripts/fetch_user_id.py username password target_user
```

## 📊 Logging et Monitoring

### Système de logs

Tous les scripts utilisent un système de logging unifié qui :

- Sauvegarde les actions dans des fichiers JSON
- Trace les succès et échecs
- Fournit des statistiques détaillées
- Affiche un résumé à la fin de l'exécution

### Structure des logs

```json
{
  "username": "user123",
  "session_start": "2024-01-01T12:00:00",
  "logs": [
    {
      "timestamp": "2024-01-01T12:01:00",
      "action_type": "hashtag_like",
      "success": true,
      "details": {
        "hashtag": "fashion",
        "media_id": "123456",
        "owner_username": "user456"
      }
    }
  ],
  "stats": {
    "total_actions": 10,
    "successful_actions": 9,
    "failed_actions": 1,
    "errors": []
  }
}
```

### Répertoires de sortie

- `logs/`: Fichiers de logs JSON
- `sessions/`: Fichiers de session Instagram
- `stats/`: Statistiques et rapports

## 🔧 Configuration

### Variables d'environnement

```bash
# URL de l'API de campagne sociale (optionnel)
export SOCIAL_CAMPAIGN_API_URL="http://localhost:3000"

# Token API (optionnel)
export SOCIAL_CAMPAIGN_API_TOKEN="your_token"

# ID de campagne (optionnel)
export SOCIAL_CAMPAIGN_ID="campaign_123"
```

### Gestion des sessions

Les sessions Instagram sont automatiquement sauvegardées dans le répertoire `sessions/` pour éviter les re-authentifications fréquentes.

## 🛡️ Sécurité

### Bonnes pratiques

1. **Ne jamais commiter les credentials** dans le code
2. **Utiliser des variables d'environnement** pour les mots de passe
3. **Limiter les actions** pour éviter le spam
4. **Respecter les rate limits** d'Instagram
5. **Surveiller les logs** pour détecter les problèmes

### Rate limiting

Les scripts incluent des délais automatiques entre les actions pour respecter les limites d'Instagram :

- Likes: 30-60 secondes entre chaque like
- Messages: 60-120 secondes entre chaque message
- Récupération de données: 5-10 secondes entre les requêtes

## 🔄 Migration depuis l'ancienne version

### Anciens scripts vs nouveaux

| Ancien script | Nouveau script | Changements |
|---------------|----------------|-------------|
| `search_hashtags.py` | `scripts/search_hashtags.py` | Arguments nommés, logging amélioré |
| `fetch_followers.py` | `scripts/fetch_followers.py` | Arguments nommés, pagination améliorée |
| `fetch_messages.py` | `scripts/fetch_messages.py` | Arguments nommés, validation améliorée |
| `send_message.py` | `scripts/send_message.py` | Arguments nommés, logging détaillé |
| `like_random_posts.py` | `scripts/like_posts.py --mode random` | Unifié avec les autres modes de like |
| `fetch_user_id.py` | `scripts/fetch_user_id.py` | Arguments nommés, logging ajouté |

### Exemple de migration

**Ancien :**
```bash
python search_hashtags.py username password fashion recent 20
```

**Nouveau :**
```bash
python scripts/search_hashtags.py username password fashion --action recent --amount 20
```

## 🐛 Dépannage

### Erreurs courantes

1. **Erreur d'authentification**
   - Vérifier les credentials
   - Supprimer le fichier de session et réessayer

2. **Rate limit atteint**
   - Attendre quelques minutes
   - Réduire la fréquence des actions

3. **Utilisateur privé**
   - L'utilisateur doit être suivi pour accéder à ses données

4. **Erreur de réseau**
   - Vérifier la connexion internet
   - Réessayer après quelques minutes

### Debug

Pour activer le mode debug, ajouter `--log-dir debug` aux commandes :

```bash
python scripts/search_hashtags.py username password fashion --log-dir debug
```

## 📈 Améliorations futures

- [ ] Support des stories Instagram
- [ ] Gestion des commentaires
- [ ] Système de planification des actions
- [ ] Interface web pour la configuration
- [ ] Intégration avec l'API Rails
- [ ] Support multi-comptes
- [ ] Métriques avancées et rapports
