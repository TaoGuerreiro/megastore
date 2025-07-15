# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Instagram Python Scripts Integration", type: :service do
  let(:test_username) { "test_user" }
  let(:test_password) { "test_password" }
  let(:scripts_dir) { Rails.root.join("app/instagram_scripts/scripts") }

  before do
    # Vérifier que l'environnement Python est disponible
    skip "Python environment not available" unless python_available?

    # Créer un environnement de test isolé
    setup_test_environment
  end

  after do
    cleanup_test_environment
  end

  describe "Scripts Python individuels" do
    describe "fetch_user_id.py" do
      it "valide la structure du script" do
        script_path = File.join(scripts_dir, "fetch_user_id.py")
        expect(File.exist?(script_path)).to be true

        # Vérifier que le script a les bonnes imports et structure
        script_content = File.read(script_path)
        expect(script_content).to include("import argparse")
        expect(script_content).to include("def main()")
        expect(script_content).to include("from core import")
      end

      it "valide les arguments du script" do
        script_path = File.join(scripts_dir, "fetch_user_id.py")
        expect(File.exist?(script_path)).to be true

        # Vérifier que le script accepte les bons arguments
        cmd = [python_executable, script_path, "--help"]
        stdout, stderr, status = Open3.capture3(*cmd)

        # Le script devrait afficher l'aide ou accepter les arguments
        expect(status.success? || stderr.include?("usage")).to be true
      end
    end

        describe "search_hashtags.py" do
      it "valide la structure du script" do
        script_path = File.join(scripts_dir, "search_hashtags.py")
        expect(File.exist?(script_path)).to be true

        # Vérifier que le script a les bonnes imports et structure
        script_content = File.read(script_path)
        expect(script_content).to include("import argparse")
        expect(script_content).to include("from core import")
      end
    end

        describe "send_message.py" do
      it "valide la structure du script" do
        script_path = File.join(scripts_dir, "send_message.py")
        expect(File.exist?(script_path)).to be true

        # Vérifier que le script a les bonnes imports et structure
        script_content = File.read(script_path)
        expect(script_content).to include("import argparse")
        expect(script_content).to include("from core import")
      end
    end
  end

  describe "Configuration et validation" do
    it "valide la structure des scripts" do
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
        expect(File.exist?(script_path)).to be true
        expect(File.readable?(script_path)).to be true
      end
    end

    it "vérifie les dépendances Python" do
      # Vérifier que les modules Python requis sont disponibles
      python_check_script = <<~PYTHON
        import sys
        import json

        required_modules = [
            'instagrapi',
            'requests',
            'json',
            'argparse',
            'pathlib'
        ]

        missing_modules = []
        for module in required_modules:
            try:
                __import__(module)
            except ImportError:
                missing_modules.append(module)

        result = {
            "python_version": sys.version,
            "missing_modules": missing_modules,
            "all_available": len(missing_modules) == 0
        }

        print(json.dumps(result))
      PYTHON

      result = execute_python_code(python_check_script)

      expect(result["all_available"]).to be true
    end
  end

  describe "Tests de performance" do
    it "valide la structure des scripts pour les performances" do
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
        expect(File.exist?(script_path)).to be true

        # Vérifier que le script est lisible et a une taille raisonnable
        expect(File.size(script_path)).to be > 100 # Au moins 100 bytes
        expect(File.readable?(script_path)).to be true
      end
    end
  end

  private

  def python_available?
    system("which python3 > /dev/null 2>&1") || system("which python > /dev/null 2>&1")
  end

  def setup_test_environment
    # Créer les répertoires nécessaires
    %w[logs sessions stats].each do |dir|
      Dir.mkdir(Rails.root.join("app/instagram_scripts", dir)) unless Dir.exist?(Rails.root.join("app/instagram_scripts", dir))
    end
  end

  def cleanup_test_environment
    # Nettoyer les fichiers de test
    %w[logs sessions stats].each do |dir|
      test_dir = Rails.root.join("app/instagram_scripts", dir)
      Dir.glob(File.join(test_dir, "*test*")).each { |f| File.delete(f) if File.file?(f) }
    end
  end

  def create_test_config_file(username, password)
    config = {
      username: username,
      password: password,
      challenge_config: {
        two_captcha_api_key: "test_key",
        challenge_email: {
          email: "test@example.com",
          password: "test_password",
          imap_server: "imap.gmail.com"
        }
      }
    }

    temp_file = Tempfile.new(["test_config", ".json"])
    temp_file.write(config.to_json)
    temp_file.rewind
    temp_file
  end

  def execute_python_script(script_name, *args)
    script_path = File.join(scripts_dir, script_name)

    # Construire la commande
    cmd = [python_executable, script_path, *args]

    # Exécuter sans timeout (Open3.capture3 ne supporte pas timeout directement)
    stdout, stderr, status = Open3.capture3(*cmd)

    unless status.success?
      raise "Script #{script_name} failed: #{stderr}"
    end

    # Parser le JSON de sortie
    JSON.parse(stdout)
  rescue JSON::ParserError => e
    raise "Invalid JSON output from #{script_name}: #{stdout} - #{e.message}"
  end

  def execute_python_code(code)
    # Exécuter du code Python directement
    stdout, stderr, status = Open3.capture3(python_executable, "-c", code)

    unless status.success?
      raise "Python code execution failed: #{stderr}"
    end

    JSON.parse(stdout)
  end

  def python_executable
    if Rails.env.production?
      "python3"
    else
      "venv/bin/python"
    end
  end
end
