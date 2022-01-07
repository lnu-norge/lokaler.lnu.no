# frozen_string_literal: true

# ./lib/tasks/css_packer.rake

desc "Packs all CSS files from app/assets/tailwind_stylesheets into app/assets/application.tailwind.css
      then runs the tailwind build"
task pack_css: :environment do
  files = Dir["./app/assets/tailwind_stylesheets/**/*.css"]

  File.open("./app/assets/stylesheets/application.tailwind.css", "w") do |main_file|
    main_file.write("/* GENERATED FILE! */\n")
    main_file.write("@tailwind base;\n")
    main_file.write("@tailwind components;\n")
    main_file.write("@tailwind utilities;\n")

    files.each do |file_path|
      File.open(file_path, "r") do |file|
        loop do
          main_file.write(file.readline)
        rescue StandardError
          main_file.write("\n")
          break
        end
      end
    end
  end

  Rake::Task["tailwindcss:build"].invoke
end
