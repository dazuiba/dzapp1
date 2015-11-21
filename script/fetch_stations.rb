require 'open-uri'
require 'nokogiri'

# class StationDoc
#   attr_accessor :json_obj
#   def self.from_xml_doc(xml_doc)
#     json_obj = {}
#     json_obj["version"] = xml_doc.css("bd>version").text
#     json_obj["timeline"] = xml_doc.css("bd>timeline").text
#
#     json_obj["stations"] = xml_doc.css("stationlist>s").map do |e|
#       station = {}
#       e.children.each{|s| station[s.name] = s.text }
#
#       { :code => s["c"],
#         :name => s["n"],
#         :py => s["jp"],
#         :pinyin => s["py"],
#         :p_code => s["o"],
#         :position => s["i"],
#         :qs=> s["qs"] }
#     end
#
#   end
#
#
#   def ini
#
#   end
#
#
#   def version
#     @xml_doc.css("bd>version").text
#   end
#
#   def timeline
#     @xml_doc.css("bd>timeline").text
#   end
# end

class StationFetcher
  DEST_DIR = File.expand_path(__FILE__+'/../'+'../public/stations')
  def self.fetch
    
    
    current_file = Dir["#{DEST_DIR}/stations_*.json"].first
    
    current_version = nil
    
    if current_file
      File.basename(current_file) =~ /stations_(\d\.\d+).json/
      current_version = $1
    end
    
      xml_url ="https://jt.rsscc.com/trainnet/refreshStation.action?pid=2005&uid=231818eeaf0404854&uuid=846F0B04-86F9-47DB-BB4C-CC3CFFEB2AA3&p=appstore,ios,9.1,gtgj,3.8,iPhone6.2,0&sid=E09BEFFA&fileversion=1.0105"
    
    new_json =  _json_from_xml_doc Nokogiri::XML(open(xml_url)) 
    new_version = new_json["version"]
    
    puts "version:#{new_version} vs #{current_version}"
    if current_version == nil || (new_version.to_f > current_version.to_f)
      # do update
      
      dest_file = "#{DEST_DIR}/stations_#{new_version}.json"
      
      puts "do update-> #{dest_file}"
      
      File.open(dest_file,"w") do |file|
        file << new_json.to_s
      end
    else   
      puts "no changes"
    end
    puts "completed!"
    
  end
  
  
  
  def self._json_from_xml_doc(xml_doc)
    json_obj = {}
    json_obj["version"] = xml_doc.css("bd>version").text
    json_obj["timeline"] = xml_doc.css("bd>timeline").text
    
    json_obj["stations"] = xml_doc.css("stationlist>s").map do |e|
      s = {}
      e.children.each{|child| s[child.name] = child.text }
      
      { :code => s["c"],
        :name => s["n"],
        :py => s["jp"],
        :pinyin => s["py"],
        :p_code => s["o"],
        :position => s["i"],  
        :qs=> s["qs"] }
    end
    json_obj
  end
  
end

if $0 == __FILE__
  puts "Run"
  StationFetcher.fetch
end