class Dog
  attr_accessor :id,:name,:breed

  # def initialize(id:, name:,breed:)
  def initialize(attrib)
    # puts "**#{attrib}"
    # @name=name
    @name=attrib[:name]
    # @breed=breed
    @breed=attrib[:breed]
    # @id=id
    @id=attrib[:id]
  end #initialize


  def save
    if !@id.nil?
      #run update instead
    else
      sql = "INSERT INTO dogs (name,breed) VALUES (?,?)"
      DB[:conn].execute(sql,@name,@breed)
      sql = "SELECT last_insert_rowid() FROM dogs"
      @id = DB[:conn].execute(sql)[0][0]
    end #if
    self
  end #save

  def update
    # puts "-----------#{@id}"
    sql = "UPDATE dogs SET name = ? WHERE id = ?"
    DB[:conn].execute(sql,@name,@id)
    sql = "UPDATE dogs SET breed = ? WHERE id = ?"
    DB[:conn].execute(sql,@breed,@id)
  end #update

  def self.create(name:, breed:)
     # Dog ::create takes in a hash of attributes and uses metaprogramming to create a new dog object.
     # Then it uses the #save method to save that dog to the database
    # puts "******#{name} #{breed}"
    d = Dog.new(name: name,breed: breed)
    d.save
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id    INTEGER PRIMARY KEY,
        name  TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end #create_table

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL

    DB[:conn].execute(sql)
  end #drop_table

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    row = DB[:conn].execute(sql,id)
    # puts "****#{row}"
    Dog.new(name: row[0][1],breed: row[0][2],id: row[0][0])
  end #find_by_id

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
    dog_data = DB[:conn].execute(sql,name)[0]
    # puts "*****#{dog_data}"
    Dog.new(id: dog_data[0],name: dog_data[1], breed: dog_data[2])
  end #find_by_name

  def self.find_or_create_by(name:, breed:)
    # puts "*********#{name} #{breed} "
    sql = "SELECT * FROM dogs WHERE name = ? INTERSECT SELECT * FROM dogs WHERE breed = ?"
    dog_data = DB[:conn].execute(sql,name,breed)
    # puts "*********#{dog_data} :: #{dog_data.length}"
    if dog_data.length > 0 #exists
      #use create
      # dog_data = dog_data[0]
      # dog = Dog.create(name: dog_data[0][1], breed: dog_data[0][2], id: dog_data[0][0])
      # dog = Dog.new(name: dog_data[0][1], breed: dog_data[0][2], id: dog_data[0][0])
      # dog = Dog.new( dog_data[0][1], dog_data[0][2], dog_data[0][0])
      dog = Dog.find_by_id(dog_data[0][0])
    else  #dog doesnt exsit in db
      # dog = Dog.create(name: dog_data[0][1], breed: dog_data[0][2])
      dog = Dog.create(name: name, breed: breed)
      # dog.save
    end #if
    dog
    # puts "*****#"
  end #find_or_create_by

  def self.new_from_db(row)
    # puts "******#{row}"
    Dog.new(name: row[1],breed: row[2], id: row[0])
  end #new_from_db
end #class
