Author.destroy_all

store = Store.find_by(slug: "ttt")

authors_dir = Rails.root.join('db', 'fixtures', 'authors')

if Dir.exist?(authors_dir)
  # Récupérez tous les fichiers d'images dans le dossier spécifié
  Dir.foreach(authors_dir) do |filename|
    next if filename == '.' || filename == '..'  # Ignorez les répertoires . et ..

    # Utilisez File.basename pour obtenir le nom de fichier sans l'extension
    nickname = File.basename(filename, File.extname(filename))

    # Créez un nouvel auteur avec le nickname et le store
    author = Author.create(
      nickname: nickname,
      store: store,
      bio: "Lorem ipsum dolor sit amet, consectetuer adipiscing
      elit, sed diam nonummy nibh euismod tincidunt ut
      Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy
      laoreet dolore magna aliquam erat volutpat. Ut wisi
      enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea
      nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut
      commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie conse-
      wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit
      MAUREEN GUÉRIN NICOLAS GENDRON SOPHIE LEULLIER TIM THAUVIN TOTH’S
      quat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit
      lobortis nisl ut aliquip ex ea com. Lorem ipsum dolor sit amet, consectetuer
      praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.
      adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore
      Lorem ipsum dolor sit amet, cons ectetuer adipiscing elit, sed diam nonummy nibh euismod tinci",
      website: "www.#{nickname.parameterize}.com")
    file = File.open(File.join(authors_dir, filename))
    author.avatar.attach(io: file, filename: "nes.png", content_type: "image/png")
    author.save
  end
else
  puts "Le répertoire #{authors_dir} n'existe pas."
end
