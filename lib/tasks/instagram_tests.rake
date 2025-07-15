# frozen_string_literal: true

namespace :instagram do
  desc "Exécuter tous les tests Instagram (RSpec + Python)"
  task test: :environment do
    puts "🧪 Démarrage des tests Instagram..."

    # Tests RSpec
    puts "\n📋 Tests RSpec..."
    system("bundle exec rspec spec/services/instagram/ --format documentation")

    # Tests Python
    puts "\n🐍 Tests Python..."
    python_test_file = Rails.root.join("app/instagram_scripts/tests/test_scripts.py")

    if File.exist?(python_test_file)
      python_executable = Rails.env.production? ? "python3" : "venv/bin/python"
      system("#{python_executable} #{python_test_file}")
    else
      puts "⚠️  Fichier de tests Python non trouvé: #{python_test_file}"
    end

    puts "\n✅ Tests Instagram terminés"
  end

  desc "Tests RSpec uniquement"
  task test_rspec: :environment do
    puts "🧪 Tests RSpec Instagram..."
    system("bundle exec rspec spec/services/instagram/ --format documentation")
  end

  desc "Tests Python uniquement"
  task test_python: :environment do
    puts "🐍 Tests Python Instagram..."
    python_test_file = Rails.root.join("app/instagram_scripts/tests/test_scripts.py")

    if File.exist?(python_test_file)
      python_executable = Rails.env.production? ? "python3" : "venv/bin/python"
      system("#{python_executable} #{python_test_file}")
    else
      puts "❌ Fichier de tests Python non trouvé: #{python_test_file}"
    end
  end

  desc "Tests d'intégration Python-Rails"
  task test_integration: :environment do
    puts "🔗 Tests d'intégration Python-Rails..."
    system("bundle exec rspec spec/services/instagram/python_scripts_integration_spec.rb --format documentation")
  end

  desc "Vérifier l'environnement Python"
  task check_python: :environment do
    puts "🔍 Vérification de l'environnement Python..."

    # Vérifier Python
    python_executable = Rails.env.production? ? "python3" : "venv/bin/python"
    python_version = `#{python_executable} --version 2>&1`.strip

    if $?.success?
      puts "✅ Python: #{python_version}"
    else
      puts "❌ Python non disponible"
      exit 1
    end

    # Vérifier les dépendances
    puts "\n📦 Vérification des dépendances Python..."
    dependencies = %w[instagrapi requests]

    dependencies.each do |dep|
      result = system("#{python_executable} -c \"import #{dep}\" 2>/dev/null")
      if result
        puts "✅ #{dep}"
      else
        puts "❌ #{dep} manquant"
      end
    end

    # Vérifier la structure des scripts
    puts "\n📁 Vérification de la structure des scripts..."
    scripts_dir = Rails.root.join("app/instagram_scripts/scripts")
    required_scripts = %w[
      fetch_user_id.py
      search_hashtags.py
      send_message.py
      fetch_messages.py
      fetch_followers.py
      like_posts.py
      engagement.py
    ]

    required_scripts.each do |script|
      script_path = File.join(scripts_dir, script)
      if File.exist?(script_path)
        puts "✅ #{script}"
      else
        puts "❌ #{script} manquant"
      end
    end
  end

  desc "Installer les dépendances Python"
  task install_python: :environment do
    puts "📦 Installation des dépendances Python..."

    python_executable = Rails.env.production? ? "python3" : "venv/bin/python"

    # Créer l'environnement virtuel si nécessaire
    if !Rails.env.production? && !File.exist?(Rails.root.join("app/instagram_scripts/venv"))
      puts "🔧 Création de l'environnement virtuel..."
      system("cd app/instagram_scripts && python3 -m venv venv")
    end

    # Installer les dépendances
    dependencies = %w[
      instagrapi
      requests
      2captcha-python
      Pillow
    ]

    dependencies.each do |dep|
      puts "📦 Installation de #{dep}..."
      system("#{python_executable} -m pip install #{dep}")
    end

    puts "✅ Dépendances Python installées"
  end

  desc "Lancer un test rapide des scripts"
  task quick_test: :environment do
    puts "⚡ Test rapide des scripts Instagram..."

    # Test simple avec fetch_user_id.py
    scripts_dir = Rails.root.join("app/instagram_scripts/scripts")
    python_executable = Rails.env.production? ? "python3" : "venv/bin/python"

    # Créer un fichier de config temporaire
    config = {
      username: "test_user",
      password: "test_password",
      challenge_config: {}
    }

    require "tempfile"
    temp_file = Tempfile.new(["test_config", ".json"])
    temp_file.write(config.to_json)
    temp_file.rewind

    begin
      # Test avec un handle valide (instagram)
      puts "🧪 Test de fetch_user_id.py..."
      result = system("#{python_executable} #{scripts_dir}/fetch_user_id.py #{temp_file.path} instagram")

      if result
        puts "✅ fetch_user_id.py fonctionne"
      else
        puts "❌ fetch_user_id.py a échoué"
      end
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  desc "Générer un rapport de couverture des tests"
  task coverage: :environment do
    puts "📊 Génération du rapport de couverture..."

    # Tests RSpec avec SimpleCov
    puts "📋 Couverture RSpec..."
    system("COVERAGE=true bundle exec rspec spec/services/instagram/ --format documentation")

    # Ouvrir le rapport de couverture
    coverage_file = Rails.root.join("coverage/index.html")
    if File.exist?(coverage_file)
      puts "📊 Rapport de couverture généré: #{coverage_file}"
      if RbConfig::CONFIG["host_os"] =~ /darwin/
        system("open #{coverage_file}")
      elsif RbConfig::CONFIG["host_os"] =~ /linux/
        system("xdg-open #{coverage_file}")
      end
    end
  end
end
