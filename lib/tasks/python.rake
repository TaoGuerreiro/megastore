namespace :python do
  desc "Installer les dépendances Python"
  task :install do
    sh "pip3 install instagrapi Pillow"
  end
end
