# frozen_string_literal: true

module Instagram
  # Test unifié des services Instagram
  class TestUnified
    def self.run_all_tests
      puts "🧪 Test unifié des services Instagram..."
      puts "=" * 60

      test_results = []

      # Test 1: Vérifier la structure des fichiers
      test_results << test_file_structure

      # Test 2: Vérifier les services
      test_results << test_services

      # Test 3: Vérifier les scripts Python
      test_results << test_python_scripts

      # Test 4: Vérifier l'index
      test_results << test_index

      # Afficher les résultats
      display_results(test_results)

      # Retourner le succès global
      test_results.all? { |result| result[:success] }
    end

    private

    def self.test_file_structure
      puts "  📁 Test de la structure des fichiers..."

      required_files = [
        "base_service.rb",
        "fetch_user_id_service.rb",
        "fetch_messages_service.rb",
        "send_message_service.rb",
        "engagement_service.rb",
        "index.rb",
        "README.md",
        "MIGRATION_SUMMARY.md"
      ]

      missing_files = []

      required_files.each do |file|
        file_path = Rails.root.join("app/services/instagram", file)
        if File.exist?(file_path)
          puts "    ✅ #{file}"
        else
          missing_files << file
          puts "    ❌ #{file} - MANQUANT"
        end
      end

      # Vérifier qu'il n'y a plus d'anciens fichiers
      old_files = [
        "fetch_user_id.rb",
        "fetch_messages.rb",
        "send_message.rb",
        "compatibility.rb",
        "engagement_controller.rb"
      ]

      old_files.each do |file|
        file_path = Rails.root.join("app/services/instagram", file)
        if File.exist?(file_path)
          puts "    ⚠️ #{file} - ANCIEN FICHIER À SUPPRIMER"
        else
          puts "    ✅ #{file} - SUPPRIMÉ"
        end
      end

      {
        name: "Structure des fichiers",
        success: missing_files.empty?,
        details: missing_files.empty? ? "Tous les fichiers requis sont présents" : "Fichiers manquants: #{missing_files.join(', ')}"
      }
    end

    def self.test_services
      puts "  🔧 Test des services..."

      services = [
        { name: "BaseService", class: Instagram::BaseService },
        { name: "FetchUserIdService", class: Instagram::FetchUserIdService },
        { name: "FetchMessagesService", class: Instagram::FetchMessagesService },
        { name: "SendMessageService", class: Instagram::SendMessageService },
        { name: "EngagementService", class: Instagram::EngagementService }
      ]

      failed_services = []

      services.each do |service|
        klass = service[:class]

        # Vérifier que la classe existe
        if klass.nil?
          failed_services << "#{service[:name]} - CLASSE MANQUANTE"
          puts "    ❌ #{service[:name]} - CLASSE MANQUANTE"
          next
        end

        # Vérifier les méthodes requises
        if service[:name] == "BaseService"
          if klass.respond_to?(:execute_script) && klass.respond_to?(:validate_credentials)
            puts "    ✅ #{service[:name]}"
          else
            failed_services << "#{service[:name]} - MÉTHODES MANQUANTES"
            puts "    ❌ #{service[:name]} - MÉTHODES MANQUANTES"
          end
        elsif klass.respond_to?(:call)
          puts "    ✅ #{service[:name]}"
        else
          failed_services << "#{service[:name]} - MÉTHODE CALL MANQUANTE"
          puts "    ❌ #{service[:name]} - MÉTHODE CALL MANQUANTE"
        end
      rescue StandardError => e
        failed_services << "#{service[:name]} - ERREUR: #{e.message}"
        puts "    ❌ #{service[:name]} - ERREUR: #{e.message}"
      end

      {
        name: "Services",
        success: failed_services.empty?,
        details: failed_services.empty? ? "Tous les services fonctionnent" : "Échecs: #{failed_services.join(', ')}"
      }
    end

    def self.test_python_scripts
      puts "  🐍 Test des scripts Python..."

      scripts_dir = Rails.root.join("app/instagram_scripts/scripts")
      required_scripts = [
        "fetch_user_id.py",
        "fetch_messages.py",
        "send_message.py",
        "like_posts.py",
        "search_hashtags.py",
        "fetch_followers.py",
        "engagement.py"
      ]

      missing_scripts = []

      required_scripts.each do |script|
        script_path = File.join(scripts_dir, script)
        if File.exist?(script_path)
          puts "    ✅ #{script}"
        else
          missing_scripts << script
          puts "    ❌ #{script} - MANQUANT"
        end
      end

      {
        name: "Scripts Python",
        success: missing_scripts.empty?,
        details: missing_scripts.empty? ? "Tous les scripts existent" : "Scripts manquants: #{missing_scripts.join(', ')}"
      }
    end

    def self.test_index
      puts "  📋 Test de l'index..."

      begin
        # Charger l'index
        require_relative "index"

        # Tester les méthodes utilitaires
        available_services = Instagram.available_services
        puts "    ✅ Services disponibles: #{available_services.join(', ')}"

        # Tester la méthode test_all_services
        test_results = Instagram.test_all_services
        failed_tests = test_results.select { |_, result| result[:status] == :error }

        if failed_tests.empty?
          puts "    ✅ Tous les tests de services passent"
        else
          puts "    ❌ Échecs dans les tests: #{failed_tests.keys.join(', ')}"
        end

        {
          name: "Index",
          success: failed_tests.empty?,
          details: failed_tests.empty? ? "Index fonctionne correctement" : "Échecs: #{failed_tests.keys.join(', ')}"
        }
      rescue StandardError => e
        {
          name: "Index",
          success: false,
          details: "Erreur: #{e.message}"
        }
      end
    end

    def self.display_results(test_results)
      puts "\n" + ("=" * 60)
      puts "📊 RÉSULTATS DES TESTS UNIFIÉS"
      puts "=" * 60

      passed = 0
      total = test_results.length

      test_results.each do |result|
        status = result[:success] ? "✅ PASS" : "❌ FAIL"
        puts "#{status} #{result[:name]}"
        puts "   #{result[:details]}" unless result[:success]
        passed += 1 if result[:success]
      end

      puts "\n🎯 Résultat: #{passed}/#{total} tests réussis"

      if passed == total
        puts "🎉 Tous les tests sont passés ! L'unification est réussie."
        puts "✨ Les services Instagram sont maintenant unifiés et prêts à l'emploi."
      else
        puts "⚠️ Certains tests ont échoué. Vérifiez les erreurs ci-dessus."
      end
    end
  end
end
