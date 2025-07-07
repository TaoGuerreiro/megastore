# frozen_string_literal: true
"""
Script de migration pour faciliter la transition depuis l'ancienne version
"""

import os
import shutil
import argparse
from pathlib import Path


def migrate_old_scripts():
    """Migrer les anciens scripts vers la nouvelle structure"""

    # Créer les nouveaux répertoires
    new_dirs = ["core", "services", "scripts", "logs", "sessions"]
    for dir_name in new_dirs:
        Path(dir_name).mkdir(exist_ok=True)

    print("✅ Répertoires créés")

    # Sauvegarder les anciens scripts
    backup_dir = Path("backup_old_scripts")
    backup_dir.mkdir(exist_ok=True)

    old_scripts = [
        "base_instagram_client.py",
        "search_hashtags.py",
        "fetch_followers.py",
        "fetch_messages.py",
        "send_message.py",
        "like_random_posts.py",
        "fetch_user_id.py",
        "instagram_engagement_controller.py"
    ]

    for script in old_scripts:
        if Path(script).exists():
            shutil.copy2(script, backup_dir / script)
            print(f"📦 Sauvegardé: {script}")

    print(f"✅ Anciens scripts sauvegardés dans {backup_dir}")

    # Créer un fichier de compatibilité
    create_compatibility_wrapper()

    print("✅ Migration terminée !")
    print("\n📋 Prochaines étapes:")
    print("1. Tester les nouveaux scripts")
    print("2. Mettre à jour vos scripts d'automatisation")
    print("3. Supprimer les anciens scripts si tout fonctionne")
    print("\n📖 Consultez le README.md pour plus d'informations")


def create_compatibility_wrapper():
    """Créer des wrappers de compatibilité pour les anciens scripts"""

    # Wrapper pour search_hashtags.py
    wrapper_content = '''#!/usr/bin/env python3
# frozen_string_literal: true
"""
Wrapper de compatibilité pour search_hashtags.py
Utilisez: python scripts/search_hashtags.py à la place
"""

import sys
import subprocess
from pathlib import Path

def main():
    if len(sys.argv) < 4:
        print('{"error": "Usage: search_hashtags.py <username> <password> <hashtag_name> [action] [amount] [cursor]"}')
        sys.exit(1)

    username = sys.argv[1]
    password = sys.argv[2]
    hashtag_name = sys.argv[3]

    # Construire la nouvelle commande
    cmd = ["python", "scripts/search_hashtags.py", username, password, hashtag_name]

    # Ajouter les options si fournies
    if len(sys.argv) > 4:
        cmd.extend(["--action", sys.argv[4]])
    if len(sys.argv) > 5:
        cmd.extend(["--amount", sys.argv[5]])
    if len(sys.argv) > 6:
        cmd.extend(["--cursor", sys.argv[6]])

    # Exécuter la nouvelle commande
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f'{{"error": "Erreur lors de l\'exécution: {e}"}}')
        sys.exit(1)

if __name__ == "__main__":
    main()
'''

    with open("search_hashtags_compat.py", "w") as f:
        f.write(wrapper_content)

    # Rendre le fichier exécutable
    os.chmod("search_hashtags_compat.py", 0o755)

    print("🔧 Wrapper de compatibilité créé: search_hashtags_compat.py")


def show_migration_guide():
    """Afficher le guide de migration"""

    guide = """
🔄 GUIDE DE MIGRATION - Scripts Instagram

📋 CHANGEMENTS PRINCIPAUX:

1. NOUVELLE STRUCTURE:
   ├── core/           # Modules de base
   ├── services/       # Services spécialisés
   ├── scripts/        # Scripts d'exécution
   └── logs/           # Fichiers de logs

2. NOUVELLE SYNTAXE:
   Ancien: python search_hashtags.py username password fashion recent 20
   Nouveau: python scripts/search_hashtags.py username password fashion --action recent --amount 20

3. LOGGING AMÉLIORÉ:
   - Logs JSON structurés
   - Statistiques détaillées
   - Traçabilité complète

📝 MIGRATION PAR SCRIPT:

search_hashtags.py:
  Ancien: python search_hashtags.py username password fashion recent 20
  Nouveau: python scripts/search_hashtags.py username password fashion --action recent --amount 20

fetch_followers.py:
  Ancien: python fetch_followers.py username password target_user 100
  Nouveau: python scripts/fetch_followers.py username password target_user --limit 100

fetch_messages.py:
  Ancien: python fetch_messages.py username password 24 123456789
  Nouveau: python scripts/fetch_messages.py username password 123456789 --hours-back 24

send_message.py:
  Ancien: python send_message.py username password 123456789 "message"
  Nouveau: python scripts/send_message.py username password 123456789 "message"

like_random_posts.py:
  Ancien: python like_random_posts.py username password 123456789 2
  Nouveau: python scripts/like_posts.py username password --mode random --target 123456789 --count 2

fetch_user_id.py:
  Ancien: python fetch_user_id.py username password handle
  Nouveau: python scripts/fetch_user_id.py username password handle

🔧 NOUVELLES FONCTIONNALITÉS:

1. Arguments nommés (--action, --limit, etc.)
2. Logging unifié avec fichiers JSON
3. Gestion d'erreurs améliorée
4. Validation des paramètres
5. Statistiques détaillées
6. Support de la pagination avancée

📊 MONITORING:

Les nouveaux scripts génèrent automatiquement:
- Fichiers de logs dans logs/
- Sessions Instagram dans sessions/
- Statistiques détaillées
- Résumés d'exécution

⚠️ POINTS D'ATTENTION:

1. Les anciens scripts sont sauvegardés dans backup_old_scripts/
2. Testez les nouveaux scripts avant de supprimer les anciens
3. Mettez à jour vos scripts d'automatisation
4. Consultez le README.md pour plus de détails

🚀 PROCHAINES ÉTAPES:

1. Tester les nouveaux scripts
2. Mettre à jour vos automatisations
3. Supprimer les anciens scripts si tout fonctionne
4. Configurer le monitoring si nécessaire
"""

    print(guide)


def main():
    """Fonction principale"""
    parser = argparse.ArgumentParser(description="Migration des scripts Instagram")
    parser.add_argument("--migrate", action="store_true", help="Effectuer la migration")
    parser.add_argument("--guide", action="store_true", help="Afficher le guide de migration")

    args = parser.parse_args()

    if args.migrate:
        migrate_old_scripts()
    elif args.guide:
        show_migration_guide()
    else:
        print("Script de migration des scripts Instagram")
        print("Utilisez --migrate pour effectuer la migration")
        print("Utilisez --guide pour afficher le guide de migration")


if __name__ == "__main__":
    main()
