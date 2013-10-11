#!/usr/bin/ruby
require 'mysql'
require 'redcloth'

begin
  connection = Mysql.new 'localhost', 'root', '', 'tneppc_development'

  treatments_rs     = connection.query("SELECT invasive_plant_id, description FROM treatments")
  life_histories_rs = connection.query("SELECT invasive_plant_id, description FROM life_histories")
  # invasive_join_rs  = connection.query("SELECT treatments.invasive_plant_id, treatments.description, life_histories.description 
  #                                       FROM treatments
  #                                       JOIN life_histories
  #                                       ON treatments.invasive_plant_id=life_histories.invasive_plant_id")
  invasive_join_rs  = connection.query("SELECT treatments.invasive_plant_id, treatments.description, life_histories.description
                                        FROM treatments, life_histories
                                        WHERE treatments.invasive_plant_id = life_histories.invasive_plant_id")


  treatment_rows      = treatments_rs.num_rows #88
  life_histories_rows = life_histories_rs.num_rows #90
  invasive_rows       = invasive_join_rs.num_rows

  invasive_join_rs.each_hash do |row|
    id          = row['invasive_plant_id']
    treatment   = RedCloth.new(row['description']).to_html
    lifeHistory = RedCloth.new(row['description']).to_html

    htmlFile = File.new("Invasive#{id}.html", "w+")
    htmlFile.puts "<!DOCTYPE html>"
    htmlFile.puts "<html>"
    htmlFile.puts "<title>Invasive #{id}</title>"
    htmlFile.puts "<body>"
    htmlFile.puts "<h1>PLANT ID: #{id}</h1>"
    htmlFile.puts "TREATMENT: #{treatment}"
    htmlFile.puts "LIFE HISTORY: #{lifeHistory}"
    htmlFile.puts "</body>"
    htmlFile.puts "</html>"
  end 

rescue Mysql::Error => e
  puts e.errno
  puts e.error

ensure
  connection.close if connection
end
