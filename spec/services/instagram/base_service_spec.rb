# frozen_string_literal: true

require "rails_helper"

RSpec.describe Instagram::BaseService do
  describe ".python_executable" do
    it "retourne python3 en production" do
      allow(Rails.env).to receive(:production?).and_return(true)
      expect(described_class.python_executable).to eq("python3")
    end

    it "retourne venv/bin/python en développement" do
      allow(Rails.env).to receive(:production?).and_return(false)
      expect(described_class.python_executable).to eq("venv/bin/python")
    end
  end

  describe ".execute_script" do
    let(:script_name) { "test_script.py" }
    let(:script_path) { File.join(Instagram::BaseService::SCRIPTS_DIR, script_name) }

    before do
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with(script_path).and_return(true)
    end

    context "quand le script existe" do
      it "exécute le script avec succès" do
        allow(Open3).to receive(:capture3).and_return(['{"success": true}', "", double(success?: true)])

        result = described_class.execute_script(script_name, "arg1", "arg2")

        expect(result).to eq({ "success" => true })
      end

      it "lève une erreur si le script échoue" do
        allow(Open3).to receive(:capture3).and_return(["", "Erreur script", double(success?: false)])

        expect { described_class.execute_script(script_name) }.to raise_error(/Erreur lors de l'exécution/)
      end

      it "lève une erreur si le résultat contient une erreur" do
        allow(Open3).to receive(:capture3).and_return(['{"error": "Erreur interne"}', "", double(success?: true)])

        expect { described_class.execute_script(script_name) }.to raise_error(/Erreur dans le résultat/)
      end

      it "lève une erreur si le JSON est invalide" do
        allow(Open3).to receive(:capture3).and_return(['{"invalid json', "", double(success?: true)])

        expect { described_class.execute_script(script_name) }.to raise_error(/Erreur de parsing JSON/)
      end
    end

    context "quand le script n'existe pas" do
      it "lève une erreur" do
        allow(File).to receive(:exist?).with(script_path).and_return(false)

        expect { described_class.execute_script(script_name) }.to raise_error(/Script non trouvé/)
      end
    end
  end

  describe ".validate_credentials" do
    it "ne lève pas d'erreur avec des credentials valides" do
      expect { described_class.validate_credentials("username", "password") }.not_to raise_error
    end

    it "lève une erreur si username est vide" do
      expect { described_class.validate_credentials("", "password") }.to raise_error(ArgumentError, /Username et password sont requis/)
    end

    it "lève une erreur si password est vide" do
      expect { described_class.validate_credentials("username", "") }.to raise_error(ArgumentError, /Username et password sont requis/)
    end

    it "lève une erreur si username est nil" do
      expect { described_class.validate_credentials(nil, "password") }.to raise_error(ArgumentError, /Username et password sont requis/)
    end

    it "lève une erreur si password est nil" do
      expect { described_class.validate_credentials("username", nil) }.to raise_error(ArgumentError, /Username et password sont requis/)
    end
  end

  describe ".validate_user_id" do
    it "ne lève pas d'erreur avec un user_id valide" do
      expect { described_class.validate_user_id("123") }.not_to raise_error
      expect { described_class.validate_user_id(123) }.not_to raise_error
    end

    it "lève une erreur si user_id n'est pas un nombre" do
      expect { described_class.validate_user_id("abc") }.to raise_error(ArgumentError, /user_id doit être un nombre/)
      expect { described_class.validate_user_id("12a") }.to raise_error(ArgumentError, /user_id doit être un nombre/)
    end

    it "lève une erreur si user_id est vide" do
      expect { described_class.validate_user_id("") }.to raise_error(ArgumentError, /user_id doit être un nombre/)
    end
  end
end
