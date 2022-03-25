class TagSet
  attr_reader :versions, :jres, :oses, :feature_sets,
              :full_list, :base_tags
  attr_accessor :tag_files
  def initialize()
    @versions = ["9.0.60","8.5.77"]
    @jres = ["jre11", "jre8", "jdk17"]
    @oses = ["debian"]
    @feature_sets = ["ff","base"]
    @base_tags = gen_base_tags
    @tag_files = {}
    gen_tag_files
  end

  private
  def gen_tag_files
    tag_files = {}
    base_tags.each do |base_tag|
      @tag_files[base_tag] = []
      @tag_files[base_tag] = @tag_files[base_tag] + expand_tag(base_tag)
    end
  end

  def expand_tag(tag)
    tags = []
    options = tag.split("-")
    ver = options.shift
    exp_ver = expand_version(ver)
    exp_ver.each do |ver|
      tags = tags +  process_subopts(options, ver)
      tags = tags + [ ver ] unless existing?(ver)
    end
    tags
  end

  def existing?(tag)
    found = false
    @tag_files.keys.each do |k|
      unless @tag_files[k].include?(tag)
        #puts "not found"
      else
        found = true
      end
    end
    found
  end

  def process_subopts(options, ver)
    tags = []
    options.count.downto(1) do |x|
      options.combination(x).each do |combo|
        potential_combo = "#{ver}-#{combo.join("-")}"
        unless existing?(potential_combo)
          tags << potential_combo
        else
          #puts "did not add"
        end
      end
    end
    tags
  end

  def gen_base_tags
    base_tags = []
    versions.each do |ver|
      jres.each do |jre|
        oses.each do |os|
          feature_sets.each do |fs|
            base_tags << "#{build_tag(ver,jre,os,fs)}"
          end
        end
      end
    end
    base_tags
  end

  def build_tag(ver, jre="", os="", fs="")
    fs = "-" + fs unless fs.empty?
    os = "-" + os unless os.empty?
    jre = "-" + jre unless jre.empty?
    "#{ver}#{jre}#{os}#{fs}"
  end

  def expand_version(ver)
    cache = []
    ver_info = ver.split(".")
    cache << ver
    cache << ver_info[0]+'.'+ver_info[1]
    cache << ver_info[0]
    cache
  end
end

t = TagSet.new
#puts "final: #{t.tag_files}"
puts "tag files:"
t.tag_files.keys.each do |line|
  puts "#{t.tag_files[line].join(" ")}"
  puts " "
end

puts "readme:"
t.tag_files.keys.each do |line|
  t.tag_files[line].each do |tag|
    print "`#{tag}\`, "
  end
  puts ""
  puts ""
end

