#!/usr/bin/env python3
# frozen_string_literal: true

"""
Script de test Python simplifié pour les scripts Instagram
"""

import sys
import json
import os
from pathlib import Path

def test_imports():
    """Tester les imports des modules"""
    print("🧪 Test des imports...")

    required_modules = [
        'instagrapi',
        'requests',
        'json',
        'argparse',
        'pathlib',
        'datetime',
        'tempfile',
        'os',
        'sys'
    ]

    missing_modules = []
    for module in required_modules:
        try:
            __import__(module)
            print(f"  ✅ {module}")
        except ImportError:
            missing_modules.append(module)
            print(f"  ❌ {module}")

    if missing_modules:
        print(f"\n⚠️  Modules manquants: {', '.join(missing_modules)}")
        return False

    print("✅ Tous les imports sont OK")
    return True

def test_script_structure():
    """Tester la structure des scripts"""
    print("\n📁 Test de la structure des scripts...")

    scripts_dir = Path(__file__).parent / "scripts"
    required_scripts = [
        "fetch_user_id.py",
        "search_hashtags.py",
        "send_message.py",
        "fetch_messages.py",
        "fetch_followers.py",
        "like_posts.py",
        "engagement.py"
    ]

    missing_scripts = []
    for script in required_scripts:
        script_path = scripts_dir / script
        if script_path.exists():
            print(f"  ✅ {script}")
        else:
            missing_scripts.append(script)
            print(f"  ❌ {script}")

    if missing_scripts:
        print(f"\n⚠️  Scripts manquants: {', '.join(missing_scripts)}")
        return False

    print("✅ Tous les scripts sont présents")
    return True

def test_script_content():
    """Tester le contenu des scripts"""
    print("\n📝 Test du contenu des scripts...")

    scripts_dir = Path(__file__).parent / "scripts"
    test_scripts = ["fetch_user_id.py", "search_hashtags.py", "send_message.py"]

    for script in test_scripts:
        script_path = scripts_dir / script
        if script_path.exists():
            content = script_path.read_text()

            # Vérifications de base
            checks = [
                ("import argparse", "argparse"),
                ("from core import", "imports core"),
                ("def main()", "fonction main"),
                ("if __name__", "point d'entrée")
            ]

            script_ok = True
            for check, description in checks:
                if check in content:
                    print(f"  ✅ {script}: {description}")
                else:
                    print(f"  ❌ {script}: {description} manquant")
                    script_ok = False

            if script_ok:
                print(f"  ✅ {script}: structure OK")
            else:
                print(f"  ❌ {script}: problèmes de structure")
                return False

    print("✅ Contenu des scripts OK")
    return True

def test_python_environment():
    """Tester l'environnement Python"""
    print("\n🐍 Test de l'environnement Python...")

    print(f"  Python version: {sys.version}")
    print(f"  Python executable: {sys.executable}")
    print(f"  Working directory: {os.getcwd()}")

    # Vérifier si on est dans un environnement virtuel
    if hasattr(sys, 'real_prefix') or (hasattr(sys, 'base_prefix') and sys.base_prefix != sys.prefix):
        print("  ✅ Environnement virtuel détecté")
    else:
        print("  ⚠️  Pas d'environnement virtuel détecté")

    return True

def main():
    """Fonction principale"""
    print("🧪 Tests Python Instagram Scripts")
    print("=" * 50)

    results = []

    # Tests
    results.append(("Imports", test_imports()))
    results.append(("Structure", test_script_structure()))
    results.append(("Contenu", test_script_content()))
    results.append(("Environnement", test_python_environment()))

    # Résumé
    print("\n" + "=" * 50)
    print("📊 RÉSUMÉ DES TESTS")
    print("=" * 50)

    passed = 0
    total = len(results)

    for test_name, result in results:
        status = "✅" if result else "❌"
        print(f"{status} {test_name}")
        if result:
            passed += 1

    print(f"\n📈 Résultats: {passed}/{total} tests réussis")

    if passed == total:
        print("🎉 Tous les tests sont passés !")
        return True
    else:
        print("⚠️  Certains tests ont échoué")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
