class Dog
  attr_accessor :name, :breed, :id

  def initialize (id: nil, name:, breed:)
    @name = name
    @breed = breed
    @id = id
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def self.create (attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.new_from_db (row)
    dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_id (id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    self.new_from_db(DB[:conn].execute(sql, id)[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?;"
    row = DB[:conn].execute(sql, name, breed)

    if row != []
      dog = self.new_from_db(row[0])
    else
      attributes = {id: row[0], name: row[1], breed: row[2]}
      self.create(attributes)
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name).first)
  end

end
