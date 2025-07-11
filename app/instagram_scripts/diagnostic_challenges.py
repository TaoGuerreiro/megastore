#!/usr/bin/env python3
# frozen_string_literal: true
"""
Script de diagnostic pour analyser les patterns qui causent les challenges Instagram
"""

import os
import json
import argparse
from datetime import datetime, timedelta
from pathlib import Path


class ChallengeDiagnostic:
    """Diagnostic des patterns qui causent les challenges Instagram"""

    def __init__(self, log_dir="logs", stats_dir="stats"):
        self.log_dir = Path(log_dir)
        self.stats_dir = Path(stats_dir)

    def analyze_logs(self, username=None, days_back=7):
        """Analyser les logs pour identifier les patterns problématiques"""
        print("🔍 Analyse des logs pour identifier les patterns problématiques...")
        print("=" * 60)

        # Trouver les fichiers de logs
        log_files = []
        if username:
            pattern = f"instagram_{username}_*.json"
            log_files = list(self.log_dir.glob(pattern))
        else:
            log_files = list(self.log_dir.glob("instagram_*_*.json"))

        if not log_files:
            print("❌ Aucun fichier de log trouvé")
            return

        print(f"📁 {len(log_files)} fichiers de logs trouvés")

        # Analyser chaque fichier
        all_actions = []
        for log_file in log_files:
            try:
                with open(log_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)

                # Extraire les actions
                for log_entry in data.get("logs", []):
                    action_type = log_entry.get("action_type")
                    timestamp = log_entry.get("timestamp")
                    success = log_entry.get("success", True)

                    if timestamp:
                        action_time = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                        cutoff_time = datetime.now() - timedelta(days=days_back)

                        if action_time >= cutoff_time:
                            all_actions.append({
                                "file": log_file.name,
                                "action_type": action_type,
                                "timestamp": action_time,
                                "success": success,
                                "details": log_entry.get("details", {})
                            })
            except Exception as e:
                print(f"⚠️ Erreur lors de l'analyse de {log_file}: {e}")

        if not all_actions:
            print("❌ Aucune action trouvée dans la période spécifiée")
            return

        # Analyser les patterns
        self._analyze_action_patterns(all_actions)
        self._analyze_timing_patterns(all_actions)
        self._analyze_error_patterns(all_actions)
        self._generate_recommendations(all_actions)

    def _analyze_action_patterns(self, actions):
        """Analyser les patterns d'actions"""
        print("\n📊 ANALYSE DES PATTERNS D'ACTIONS")
        print("-" * 40)

        # Compter les types d'actions
        action_counts = {}
        for action in actions:
            action_type = action["action_type"]
            action_counts[action_type] = action_counts.get(action_type, 0) + 1

        print("Répartition des actions :")
        for action_type, count in sorted(action_counts.items(), key=lambda x: x[1], reverse=True):
            print(f"  {action_type}: {count}")

        # Analyser les volumes par heure
        hourly_volumes = {}
        for action in actions:
            hour = action["timestamp"].replace(minute=0, second=0, microsecond=0)
            hourly_volumes[hour] = hourly_volumes.get(hour, 0) + 1

        print(f"\nVolumes par heure (max 10 affichés):")
        for hour, count in sorted(hourly_volumes.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {hour.strftime('%Y-%m-%d %H:00')}: {count} actions")

        # Identifier les heures de pointe
        max_actions_per_hour = max(hourly_volumes.values()) if hourly_volumes else 0
        if max_actions_per_hour > 10:
            print(f"\n⚠️ VOLUME EXCESSIF: {max_actions_per_hour} actions/heure (recommandé: <8)")

    def _analyze_timing_patterns(self, actions):
        """Analyser les patterns de timing"""
        print("\n⏰ ANALYSE DES PATTERNS DE TIMING")
        print("-" * 40)

        if len(actions) < 2:
            print("❌ Pas assez d'actions pour analyser les patterns de timing")
            return

        # Calculer les intervalles entre actions
        intervals = []
        sorted_actions = sorted(actions, key=lambda x: x["timestamp"])

        for i in range(1, len(sorted_actions)):
            interval = (sorted_actions[i]["timestamp"] - sorted_actions[i-1]["timestamp"]).total_seconds()
            intervals.append(interval)

        if intervals:
            avg_interval = sum(intervals) / len(intervals)
            min_interval = min(intervals)
            max_interval = max(intervals)

            print(f"Intervalles entre actions:")
            print(f"  Moyenne: {avg_interval:.1f} secondes")
            print(f"  Minimum: {min_interval:.1f} secondes")
            print(f"  Maximum: {max_interval:.1f} secondes")

            # Identifier les problèmes
            if min_interval < 60:
                print(f"\n⚠️ INTERVALLES TROP COURTS: {min_interval:.1f}s (recommandé: >120s)")

            if avg_interval < 180:
                print(f"\n⚠️ INTERVALLES MOYENS TROP COURTS: {avg_interval:.1f}s (recommandé: >180s)")

        # Analyser les heures d'activité
        hour_distribution = {}
        for action in actions:
            hour = action["timestamp"].hour
            hour_distribution[hour] = hour_distribution.get(hour, 0) + 1

        print(f"\nDistribution par heure de la journée:")
        for hour in range(24):
            count = hour_distribution.get(hour, 0)
            bar = "█" * min(count, 10)  # Barre de 10 max
            print(f"  {hour:02d}h: {bar} ({count})")

        # Identifier les heures suspectes
        for hour, count in hour_distribution.items():
            if hour < 6 and count > 0:
                print(f"\n⚠️ ACTIVITÉ NOCTURNE: {count} actions à {hour}h (suspect)")

    def _analyze_error_patterns(self, actions):
        """Analyser les patterns d'erreurs"""
        print("\n❌ ANALYSE DES ERREURS")
        print("-" * 40)

        failed_actions = [a for a in actions if not a["success"]]

        if not failed_actions:
            print("✅ Aucune erreur détectée")
            return

        print(f"Nombre d'erreurs: {len(failed_actions)}")

        # Analyser les types d'erreurs
        error_types = {}
        for action in failed_actions:
            details = action.get("details", {})
            error_msg = details.get("error_message", "Unknown error")

            # Catégoriser les erreurs
            if "too many requests" in error_msg.lower():
                error_type = "Rate Limit"
            elif "challenge" in error_msg.lower():
                error_type = "Challenge"
            elif "blocked" in error_msg.lower():
                error_type = "Action Blocked"
            elif "login" in error_msg.lower():
                error_type = "Login Issue"
            else:
                error_type = "Other"

            error_types[error_type] = error_types.get(error_type, 0) + 1

        print("Types d'erreurs:")
        for error_type, count in error_types.items():
            print(f"  {error_type}: {count}")

        # Analyser la fréquence des erreurs
        if len(failed_actions) > len(actions) * 0.1:  # Plus de 10% d'erreurs
            print(f"\n⚠️ TAUX D'ERREUR ÉLEVÉ: {len(failed_actions)/len(actions)*100:.1f}%")

    def _generate_recommendations(self, actions):
        """Générer des recommandations basées sur l'analyse"""
        print("\n💡 RECOMMANDATIONS")
        print("-" * 40)

        recommendations = []

        # Analyser le volume total
        total_actions = len(actions)
        if total_actions > 100:
            recommendations.append("🔴 Réduire drastiquement le volume d'actions")

        # Analyser les intervalles
        if len(actions) >= 2:
            sorted_actions = sorted(actions, key=lambda x: x["timestamp"])
            intervals = []
            for i in range(1, len(sorted_actions)):
                interval = (sorted_actions[i]["timestamp"] - sorted_actions[i-1]["timestamp"]).total_seconds()
                intervals.append(interval)

            avg_interval = sum(intervals) / len(intervals)
            if avg_interval < 180:
                recommendations.append("🔴 Augmenter les délais entre actions (minimum 3 minutes)")

        # Analyser les heures d'activité
        hour_distribution = {}
        for action in actions:
            hour = action["timestamp"].hour
            hour_distribution[hour] = hour_distribution.get(hour, 0) + 1

        night_activity = sum(count for hour, count in hour_distribution.items() if hour < 6)
        if night_activity > 0:
            recommendations.append("🟡 Éviter l'activité nocturne (0h-6h)")

        # Analyser les erreurs
        failed_actions = [a for a in actions if not a["success"]]
        if failed_actions:
            recommendations.append("🟡 Surveiller les erreurs et ajuster les paramètres")

        # Recommandations générales
        if not recommendations:
            recommendations.append("✅ Configuration actuelle semble correcte")

        recommendations.extend([
            "📋 Appliquer les nouvelles limites de config.py",
            "⏰ Utiliser des délais de 2-5 minutes entre likes",
            "🔄 Alterner entre différents hashtags et comptes",
            "📊 Surveiller les logs régulièrement"
        ])

        for i, rec in enumerate(recommendations, 1):
            print(f"{i}. {rec}")

    def analyze_config(self):
        """Analyser la configuration actuelle"""
        print("\n⚙️ ANALYSE DE LA CONFIGURATION")
        print("-" * 40)

        try:
            from config import InstagramConfig

            rate_limits = InstagramConfig.get_rate_limits()
            delays = InstagramConfig.get_delays()
            limits = InstagramConfig.get_limits()

            print("Limites actuelles:")
            for key, value in rate_limits.items():
                print(f"  {key}: {value}")

            print(f"\nDélais actuels:")
            for key, value in delays.items():
                print(f"  {key}: {value[0]}-{value[1]} secondes")

            print(f"\nLimites de session:")
            for key, value in limits.items():
                print(f"  {key}: {value}")

            # Évaluer la configuration
            issues = []
            if rate_limits["likes_per_hour"] > 10:
                issues.append("🔴 Trop de likes par heure")
            if rate_limits["likes_per_day"] > 50:
                issues.append("🔴 Trop de likes par jour")
            if delays["likes"][0] < 120:
                issues.append("🔴 Délais entre likes trop courts")

            if issues:
                print(f"\n⚠️ Problèmes détectés:")
                for issue in issues:
                    print(f"  {issue}")
            else:
                print(f"\n✅ Configuration semble correcte")

        except ImportError:
            print("❌ Impossible d'importer la configuration")

    def generate_report(self, username=None, days_back=7):
        """Générer un rapport complet"""
        print("📋 RAPPORT DE DIAGNOSTIC DES CHALLENGES")
        print("=" * 60)
        print(f"Période analysée: {days_back} derniers jours")
        print(f"Utilisateur: {username or 'Tous'}")
        print(f"Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

        self.analyze_config()
        self.analyze_logs(username, days_back)

        print("\n" + "=" * 60)
        print("📋 RÉSUMÉ EXÉCUTIF")
        print("=" * 60)
        print("Pour éviter les challenges Instagram:")
        print("1. Réduire les volumes d'actions")
        print("2. Augmenter les délais entre actions")
        print("3. Éviter les patterns réguliers")
        print("4. Utiliser des horaires naturels")
        print("5. Surveiller les erreurs")


def main():
    parser = argparse.ArgumentParser(description="Diagnostic des patterns qui causent les challenges Instagram")
    parser.add_argument("--username", help="Nom d'utilisateur spécifique à analyser")
    parser.add_argument("--days", type=int, default=7, help="Nombre de jours à analyser (défaut: 7)")
    parser.add_argument("--log-dir", default="logs", help="Répertoire des logs (défaut: logs)")
    parser.add_argument("--stats-dir", default="stats", help="Répertoire des stats (défaut: stats)")

    args = parser.parse_args()

    diagnostic = ChallengeDiagnostic(args.log_dir, args.stats_dir)
    diagnostic.generate_report(args.username, args.days)


if __name__ == "__main__":
    main()
