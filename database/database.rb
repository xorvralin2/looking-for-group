class Database
  @@db ||= SQLite3::Database.new('./database/user_data.db')
  @@db.results_as_hash = true

  def self.execute(*args)
    @@db.execute(*args)
  end

  def self.db=(database)
    @@db = database
    @@db.results_as_hash = true
  end

  def self.clear(tables)
    if tables.include? 'users'
      execute('DROP TABLE IF EXISTS users')
      execute('CREATE TABLE users
        (id INTEGER PRIMARY KEY AUTOINCREMENT, username VARCHAR(40) NOT NULL,
         password VARCHAR(40) NOT NULL,
         email VARCHAR(100) NOT NULL,
         profile_img VARCHAR(40),
         rsn VARCHAR(40),
         stat_id INTEGER,
         dark_mode INTEGER,
         FOREIGN KEY(stat_id) REFERENCES stats(id))')
    elsif tables.include? 'stats'
      execute('DROP TABLE IF EXISTS stats')
      execute('CREATE TABLE stats
        (id INTEGER PRIMARY KEY AUTOINCREMENT,
         attack INTEGER,
         defence INTEGER,
         strength INTEGER,
         hitpoints INTEGER,
         ranged INTEGER,
         prayer INTEGER,
         magic INTEGER,
         mining INTEGER,
         herblore INTEGER,
         thieving INTEGER,
         farming INTEGER)')
    elsif tables.include? 'bosses'
      execute('DROP TABLE IF EXISTS bosses')
      execute('CREATE TABLE bosses
        (id INTEGER PRIMARY KEY AUTOINCREMENT,
         name VARCHAR(60) NOT NULL,
         boss_img VARCHAR(40),
         wiki_link VARCHAR(255))')
    elsif tables.include? 'user_boss_interests'
      execute('DROP TABLE IF EXISTS user_boss_interests')
      execute('CREATE TABLE user_boss_interests
        (user_id INTEGER NOT NULL,
         boss_id INTEGER NOT NULL,
         FOREIGN KEY(user_id) REFERENCES users(id),
         FOREIGN KEY(boss_id) REFERENCES bosses(id))')
    elsif tables.include? 'friend_relations'
      execute('DROP TABLE IF EXISTS friend_relations')
      execute('CREATE TABLE friend_relations 
        (user1 INTEGER NOT NULL,
         user2 INTEGER NOT NULL,
         FOREIGN KEY(user1) REFERENCES users(id),
         FOREIGN KEY(user2) REFERENCES users(id))')
    end
  end

  def self.insert_user(username, hashed_pwd, email, profile_img, rsn)
    stat_id = insert_stats(rsn)[0]
    execute('INSERT INTO users (username, password, email, profile_img, rsn, stat_id, dark_mode) VALUES (?, ?, ?, ?, ?, ?, ?)', 
      [username, hashed_pwd, email, profile_img, rsn, stat_id, 0])
  end

  # Returns the inserted row
  def self.insert_stats(rsn)
    begin
      converted_name = RuneScapeApi::convert_username(rsn)
    rescue ArgumentError
      converted_name = ""
    end
    stats = RuneScapeApi::get_stats(converted_name)
    @@db.execute('INSERT INTO stats (attack, defence, strength, hitpoints, ranged, prayer, magic, mining, herblore, thieving, farming) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', 
                stats.values)
    @@db.execute('SELECT * FROM stats ORDER BY id DESC LIMIT 1')[0]
  end

  def self.insert_boss(name, boss_img, wiki_link)
    execute('INSERT INTO bosses (name, boss_img, wiki_link)
                VALUES (?, ?, ?)', [name, boss_img, wiki_link])
  end

  def self.insert_user_boss_interest(username, boss_name)
    user_id = execute('SELECT id FROM users 
                          WHERE username = ?', username)
    boss_id = execute('SELECT id FROM bosses
                          WHERE name = ?', boss_name)
    execute('INSERT INTO user_boss_interests (user_id, boss_id)
                VALUES (?, ?)', [user_id, boss_id])
  end

  def self.insert_bosses()
    # Bosses
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Callisto', 'Callisto.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Chaos Elemental', 'Chaos Elemental.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Chaos Fanatic', 'Chaos Fanatic.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Commander Zilyana', 'Commander Zilyana.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) VALUES (?, ?, ?)', ['Crazy Archaeologist', 'Crazy archaeologist.png', 'oldschool.runesacpe.wiki']) 
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Dagannoth Kings', 'Dagannoth Rex.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['General Graardor', 'General Graardor.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Giant Mole', 'Giant_Mole.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Kalphite Queen', 'Kalphite Queen.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['King Black Dragon', 'King Black Dragon.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Kree\'arra', 'Kreearra.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['K\'ril Tsutsaroth', 'Kril Tsutsaroth.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Scorpia', 'Scorpia.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Venenatis', 'Venenatis.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Raids 2', 'Verzik.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Vet\'ion', 'Vetion.png', 'oldschool.runesacpe.wiki'])
    execute('INSERT INTO bosses (name, boss_img, wiki_link) 
                VALUES (?, ?, ?)', ['Raids 1', 'Xeric.png', 'oldschool.runesacpe.wiki'])
  end

  def self.get_user_by_name(name)
    User.new (execute('SELECT * FROM users WHERE username = ?', name)[0])
  end

  def self.get_bosses()
    result = execute('SELECT * FROM bosses')
    bosses = []
    result.each do |row|
      bosses << Boss.new(row)
    end
    return bosses
  end

  def self.get_boss(identfier)
    argument = identfier.to_i
    if argument != 0 # Get boss by id
      return Boss.new(execute('SELECT * FROM bosses 
                               WHERE id = ?', argument)[0])
    else # Get boss by name
      return Boss.new(execute('SELECT * FROM bosses 
                               WHERE name = ?', args[1])[0])
    end
  end

  def self.update_users_interests(user_id, interests)
    execute('DELETE FROM user_boss_interests
             WHERE user_id = ?', user_id)
    interests.each do |row|
      execute('INSERT INTO user_boss_interests 
              values (?, ?)', [user_id.to_i, row[0].to_i])
    end
  end
end
