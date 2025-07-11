# frozen_string_literal: true

class FixSocialTargetPostsLikedData < ActiveRecord::Migration[7.0]
  def up
    # Récupérer tous les social_targets
    SocialTarget.find_each do |target|
      # Si posts_liked est une chaîne de caractères, la convertir en tableau
      if target.posts_liked.is_a?(String)
        # Essayer de parser comme JSON d'abord
        begin
          parsed = JSON.parse(target.posts_liked)
          target.update_column(:posts_liked, parsed)
        rescue JSON::ParserError
          # Si ce n'est pas du JSON valide, essayer d'extraire les post_ids
          # Supposons que le format est "[]post_123" ou similaire
          if target.posts_liked.start_with?('[]')
            post_id = target.posts_liked[2..-1] # Enlever "[]"
            target.update_column(:posts_liked, [post_id])
          else
            # Si on ne peut pas parser, initialiser avec un tableau vide
            target.update_column(:posts_liked, [])
          end
        end
      elsif target.posts_liked.nil?
        # Si posts_liked est nil, initialiser avec un tableau vide
        target.update_column(:posts_liked, [])
      end
    end
  end

  def down
    # Cette migration ne peut pas être annulée de manière sûre
    # car elle corrige des données corrompues
    raise ActiveRecord::IrreversibleMigration
  end
end
