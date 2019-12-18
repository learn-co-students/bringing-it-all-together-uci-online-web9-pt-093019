class Dog
  attr_accessor :id, :name, :breed

  def initialize(attributes)
    attributes.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.create(attributes)
    dog = self.new(attributes)
    dog.save
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    breed = row[2]
    attributes = {
      id: id,
      name: name,
      breed: breed
    }
    dog = self.new(attributes)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    data = DB[:conn].execute(sql, id).first
    self.new_from_db(data)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    data = DB[:conn].execute(sql, name).first
    self.new_from_db(data)
  end

  def self.find_or_create_by(args)

    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    dog = DB[:conn].execute(sql, args[:name], args[:breed])
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(args)
    end
  end

  def save
    if self.id
      self.update
    else
        sql = <<-SQL
          INSERT INTO dogs
          VALUES (NULL, ?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
