require 'nokogiri' 
require 'yaml'

config = YAML.load_file("config.yml")

def getNode(doc, id)
  return doc.xpath('//*[@id="%s"]' % [id])
end

def create( name, title, number, color)
	file = File.new( "./karten/original/logo-karte-vorlage.svg" )  
	doc = Nokogiri::XML( file )

	# Number and name of the sheet
	nameNode = doc.xpath('//*[@id="flowPara1592"]')[0]
	nameNode.content = title %[number]

	# Image of the result
	image = doc.xpath('//*[@id="image1946"]')[0]
	image['xlink:href'] = "./karten/muster/%s.png" %[name]
	image['sodipodi:absref']="./karten/muster/%s.png" %[name]

	if(color) then
		background = getNode(doc, "rect4140-9")[0]
		background['style'] = background['style'].gsub(/#80e5ff/, color)
		background = getNode(doc, "rect4140")[0]
		background['style'] = background['style'].gsub(/#80e5ff/, color)
	end

	# example code
	example = getNode(doc, "text5935")[0]
	# Remove all content
	example.children.remove

	keywords = [ 'repeat', 'fd', 'rt', 'lt' , 'pd' , 'setpc', 'bk' , 'pu']

	line_style = "font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:22.5px;line-height:1.25;font-family:monospace;-inkscape-font-specification:monospace;fill:#000000;fill-opacity:1";
	argument_style = "fill:#5599ff;fill-opacity:1"
	command_style = "font-weight:bold;fill:#88aa00;fill-opacity:1"
	x_coord_text = 612.97662
	y_coord_text = 639.81561
	next_line_distance = 28.125

	File.open("./karten/logo/%s.lgo" %[name]) { |f| 
	  ind = 0
	  f.readlines().each { |line|
		node = example.add_child("<tspan></tspan>")[0]
		node['style'] = line_style
		node['sodipodi:role'] = "line"
		node['x'] = "%f" % x_coord_text
		node['y'] = "%f" % y_coord_text
		y_coord_text = y_coord_text + next_line_distance
		next_word = ""
		
		if(line.match?(/^\s*end/) or line.match?(/^\s*\]/)) then
			ind = ind - 2
		end
		
		if(ind > 0) then
		  ind_str = " " * ind
		  node.add_child("<tspan>%s</tspan>" %[ind_str])
		end
		
		line.split("\s").each { |word|
		  # commands
		  if(keywords.include?(word) or next_word.match?(/^command$/)) then
			keyword = node.add_child("<tspan>%s </tspan>" %[word])[0]
			keyword['style'] = command_style
			next_word = ""
		  # arguments
		  elsif(word.match?(/\d+/) or word.start_with?(":")) then
			argument = node.add_child("<tspan>%s </tspan>" %[word])[0]
			argument['style'] = argument_style
		  # everything else
		  else
			node.add_child("<tspan>%s </tspan>" %[word])[0]
		  end
		  
		  if(word.match?(/^to$/)) then
			next_word = "command"
			ind = ind + 2
		  elsif(word.match?(/^repeat$/)) then
			ind = ind + 2
		  end
		}
	  }
	}

	# Adjust the background
	y_coord_background = 605.90558
	background = getNode(doc, "rect5931")[0]
	background['height'] = y_coord_text - y_coord_background

	File.open("karten/vektorgrafiken/%s.svg" %[name], 'w') { |file| 
	  file.write(doc.to_xml) 
	}
	
	# Starting a new process to run inkscape
	processId = Process.spawn("inkscape --file=karten/vektorgrafiken/#{name}.svg --export-area-page --without-gui --export-pdf=karten/pdf/logo-karte-#{name}.pdf")

end

def getDefault(setting, default) 
	if(!setting) then
		setting = default
	end
	return setting
end

config['worksheets'].each_with_index { |element, index|
	color = "#" + getDefault(element["color"], config["settings"]["color"])
	name = "Nr.%d - " + getDefault(element['name'], element['label'].capitalize)

	create(element['label'], name, index+1, color)
}
