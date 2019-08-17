class Resource
  OBJECTS_DIR_PATH = 'objects'
  REF_DIR_PATH = 'refs'
  MAIN_BRANCH_NAME = 'HEAD'

  OBJECT_NAME = 'object'
  LIST_NAME = 'list'

  DEFAULT_RESOUCE_MAP = {
    OBJECT_NAME => '{}',
    LIST_NAME => '[]',
  }

  def self.list
    Dir.glob("#{OBJECTS_DIR_PATH}/*").map { |r| File.basename(r) }
  end

  def new_resource(name, empty_json)
    Dir.mkdir(dir(name))

    hash = Digest::SHA1.hexdigest(empty_json)

    File.open(resource_path(name, hash), 'w') do |f|
      f.write empty_json
    end

    File.open(ref_path(name), 'w') do |f|
      f.write(hash)
    end
  end

  def add_file(name, key, val)
    raise 'resource not found' unless exist_resource?(name)

    json = nil
    File.open(master_path(name), 'r') do |f|
      json = JSON.parse(f.read)
    end
    json[key] = val

    hash = Digest::SHA1.hexdigest(json.to_json)
    path = resource_path(name, hash)
    File.open(path, 'w') do |f|
      f.write(json.to_json)
    end

    File.open(ref_path(name), 'w') do |f|
      f.write(hash)
    end
  end

  def read_file(name)
    raise 'resource not found' unless exist_resource?(name)

    File.open(master_path(name)) do |f|
      return f.read
    end
  end

  private

  def exist_resource?(name)
    return false unless FileTest.exist?(dir(name))

    FileTest.exist?(master_path(name))
  end

  def ref_path(name)
    File.join(OBJECTS_DIR_PATH, name, MAIN_BRANCH_NAME)
  end

  def master_path(name)
    hash = nil
    File.open(ref_path(name)) do |f|
      hash = f.read.chomp
    end
    File.join(OBJECTS_DIR_PATH, name, hash)
  end

  def resource_path(name, hash)
    File.join(OBJECTS_DIR_PATH, name, hash)
  end

  def dir(name)
    File.join(OBJECTS_DIR_PATH, name)
  end
end
