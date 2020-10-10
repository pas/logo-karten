require 'nokogiri' 
require 'yaml'

config = YAML.load_file("config.yml")

def getNode(doc, id, fullDocument=true)
  context = fullDocument ? "" : "."
  return doc.xpath('%s//*[@id="%s"]' % [context, id])
end

$argument_style = "fill:#5599ff"
$command_style = "font-weight:bold;fill:#88aa00"

def colorize(node, line, node_name, ind, next_word, keywords)
	element = "<" + node_name + ">%s </" + node_name +">"
	line.split("\s").each { |word|
	  # commands
	  if(keywords.include?(word) or next_word.match?(/^command$/)) then
		keyword = node.add_child(element %[word])[0]
		keyword['style'] = $command_style
		next_word = ""
	  # arguments
	  elsif(word.match?(/\d+/) or word.start_with?(":")) then
		argument = node.add_child(element %[word])[0]
		argument['style'] = $argument_style
	  # everything else
	  else
		node.add_child(element %[word])[0]
	  end
	  
	  if(word.match?(/^to$/)) then
		next_word = "command"
		ind = ind + 2
	  elsif(word.match?(/^repeat$/)) then
		ind = ind + 2
	  end
	}
	
	return ind, next_word
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
		
		
		ind, next_word = colorize(node, line, "tspan", ind, next_word, keywords)
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

def nextLine(node, id)
	distance = 56.69292
	rect = getNode(node, id, false)[0]
	rect['y'] = rect['y'].to_f + distance
	node.children[0]['style'] = node.children[0]['style'].sub('font-weight:bold', 'font-weight:normal')
end

def nextHorizontalLine(node)
  distance = 53.149605
  node = node.children[0]
  line = node['d']
  all_values = line.split("H")
  m_values = all_values[0].split(",")
  y = m_values[1].to_f
  y = y + distance
  node['d'] = "%s,%f H%s" %[m_values[0], y, all_values[1]]
end

def createOverview(keywords)
	file = File.new( "./karten/original/logo-uebersicht-vorlage.svg" )
	doc = Nokogiri::XML( file )
	
	file = File.new( "./karten/original/left-table-content.svg" )
	left = Nokogiri::XML::DocumentFragment::parse( file.readlines().join(" ") )
	file = File.new( "./karten/original/right-table-content.svg" )
	right = Nokogiri::XML::DocumentFragment::parse( file.readlines().join(" ") )
	file = File.new( "./karten/original/horizontal-table-line.svg" )
	h_line = Nokogiri::XML::DocumentFragment::parse( file.readlines().join(" ") )
	file = File.new( "./karten/original/vertical-table-line.svg" )
	v_line = Nokogiri::XML::DocumentFragment::parse( file.readlines().join(" ") )
	
	# table container
	table = getNode(doc, "layer5")[0]
	# Remove all content
	table.children.remove
	
	#line container
	line = getNode(doc, "layer4")[0]
	line.children.remove
	
	# Add header
	table.add_child(left.dup)
	table.add_child(right.dup)
	line.add_child(h_line.dup)
	line.add_child(v_line.dup)
	
	keyw = keywords.map { |word| word['short'] }
	keywords.each { |keyword|
		nextLine(left , "rect3893")
		nextLine(right , "rect3925")
		
		getNode(left, "flowPara3895", false)[0].content = keyword['description']
		getNode(right, "flowPara3927", false)[0].content=""
		colorize(getNode(right, "flowPara3927", false)[0], keyword['example'], "flowSpan", 0 , "", keyw)
		
		nextHorizontalLine(h_line)
		line.add_child(h_line.dup)

		table.add_child(left.dup)
		table.add_child(right.dup)
	}
	

	
	File.open("karten/vektorgrafiken/logo-uebersicht.svg", 'w') { |file| 
	  file.write(doc.to_xml) 
	}
	
	# Starting a new process to run inkscape
	processId = Process.spawn("inkscape --file=karten/vektorgrafiken/logo-uebersicht.svg --export-area-page --without-gui --export-pdf=karten/pdf/logo-uebersicht.pdf")
end

def getDefault(setting, default) 
	if(!setting) then
		setting = default
	end
	return setting
end

def createWorksheets(config)
	config['worksheets'].each_with_index { |element, index|
		color = "#" + getDefault(element["color"], config["settings"]["color"])
		name = "Nr.%d - " + getDefault(element['name'], element['label'].capitalize)

		create(element['label'], name, index+1, color)
	}
end

createWorksheets(config)
createOverview(config['keywords'])
