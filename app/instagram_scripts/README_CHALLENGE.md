# Gestion des Challenges Instagram

Ce module permet de gérer automatiquement les challenges Instagram (CAPTCHA, codes SMS/Email, changement de mot de passe) pour éviter les interruptions lors de l'automatisation.

## 🚀 Installation

### 1. Installer les dépendances

```bash
# Pour la résolution automatique de CAPTCHA
pip install 2captcha-python

# Les autres dépendances sont déjà incluses
```

### 2. Configuration des variables d'environnement

```bash
# Clé API pour 2captcha (optionnel, pour résolution automatique de CAPTCHA)
export TWOCAPTCHA_API_KEY="votre_cle_api_2captcha"

# Configuration email pour les codes de vérification (optionnel)
export CHALLENGE_EMAIL="votre.email@gmail.com"
export CHALLENGE_EMAIL_PASSWORD="votre_mot_de_passe_email"
```

## 📋 Configuration

### Configuration dans le fichier JSON des comptes

```json
[
  {
    "username": "votre_compte_instagram",
    "password": "votre_mot_de_passe",
    "social_campagne_id": 123,
    "hashtags": [...],
    "targeted_accounts": [...],

    "challenge_email": {
      "email": "votre.email@gmail.com",
      "password": "votre_mot_de_passe_email",
      "imap_server": "imap.gmail.com"
    },

    "challenge_sms": {
      "provider": "twilio",
      "account_sid": "votre_account_sid",
      "auth_token": "votre_auth_token",
      "phone_number": "+33123456789"
    }
  }
]
```

## 🔧 Types de Challenges Gérés

### 1. CAPTCHA
- **Résolution automatique** : Via 2captcha (si configuré)
- **Résolution manuelle** : Fallback avec instructions pour l'utilisateur
- **Déclenchement** : Activité suspecte détectée par Instagram

### 2. Code de Vérification Email
- **Lecture automatique** : Via IMAP (Gmail, Outlook, etc.)
- **Extraction** : Code à 6 chiffres dans les emails Instagram
- **Déclenchement** : Nouvelle connexion ou activité suspecte

### 3. Code de Vérification SMS
- **Lecture automatique** : Via API SMS (Twilio, etc.)
- **Extraction** : Code à 6 chiffres dans les SMS Instagram
- **Déclenchement** : Vérification d'identité

### 4. Changement de Mot de Passe
- **Génération automatique** : Mot de passe sécurisé aléatoire
- **Déclenchement** : Mesure de sécurité extrême d'Instagram

## 🧪 Tests

### Test du service de challenge

```bash
python test_challenge.py --test-service
```

### Test avec un compte réel

```bash
python test_challenge.py --test-client --username VOTRE_USERNAME --password VOTRE_PASSWORD
```

### Test avec fichier de configuration

```bash
python test_challenge.py --config-file config_challenge_example.json
```

## 🔒 Sécurité

### Variables d'environnement recommandées

```bash
# Ne jamais commiter ces valeurs dans le code
export TWOCAPTCHA_API_KEY="votre_cle_secrete"
export CHALLENGE_EMAIL="email_secret@gmail.com"
export CHALLENGE_EMAIL_PASSWORD="mot_de_passe_secret"
```

### Configuration sécurisée

- Utilisez des variables d'environnement pour les secrets
- Ne stockez jamais les mots de passe en clair dans les fichiers
- Utilisez des comptes email dédiés pour les challenges
- Activez l'authentification à deux facteurs sur les comptes email

## 📊 Logs et Monitoring

Les challenges sont automatiquement loggés :

```json
{
  "timestamp": "2024-01-15T10:30:00",
  "event": "challenge_detected",
  "username": "votre_compte",
  "challenge_type": "CAPTCHA",
  "status": "resolved_automatically"
}
```

## 🚨 Dépannage

### CAPTCHA non résolu automatiquement

1. Vérifiez que la clé API 2captcha est correcte
2. Vérifiez votre solde 2captcha
3. Le script passera automatiquement en mode manuel

### Code email non trouvé

1. Vérifiez les paramètres IMAP
2. Vérifiez que l'email Instagram est bien reçu
3. Attendez quelques minutes après la demande de code

### Erreur de connexion

1. Vérifiez les identifiants Instagram
2. Vérifiez que le compte n'est pas temporairement bloqué
3. Essayez de vous connecter manuellement d'abord

## 💡 Conseils

### Réduire les challenges

1. **Espacement** : Attendez entre les actions
2. **Comportement naturel** : Simulez un utilisateur humain
3. **Sessions stables** : Réutilisez les sessions existantes
4. **Proxies** : Variez les IPs si nécessaire
5. **User-Agent réaliste** : Utilisez des métadonnées naturelles

### Configuration optimale

```json
{
  "username": "votre_compte",
  "password": "votre_mot_de_passe",
  "challenge_email": {
    "email": "compte_dedie@gmail.com",
    "password": "mot_de_passe_securise",
    "imap_server": "imap.gmail.com"
  }
}
```

## 🔄 Intégration

Le système de challenge est automatiquement intégré dans :

- `InstagramClient` : Gestion des challenges lors de la connexion
- `EngagementService` : Gestion des challenges pendant l'engagement
- Tous les scripts d'automatisation

Aucune modification de code supplémentaire n'est nécessaire !
