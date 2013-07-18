developer = ""
project = ""
copyright = ""
config = nil
require 'date'
date = DateTime.now()
formatted_date = date.strftime("%m/%d/%y")

File.open("config", 'r') { |file|
	config = file.read()
}

developer = nil
project = nil
copyright = nil
new_class = nil
superclass = nil

config.each_line { |line|
  if line.include?("Developer:")
  	developer = line.split("Developer:")[1].lstrip.rstrip
  elsif line.include?("Project:")
  	project = line.split("Project:")[1].lstrip.rstrip
  elsif line.include?("Copyright:")
	copyright = line.split("Copyright:")[1].lstrip.rstrip
  elsif line.include?("Class:")
  	new_class = line.split("Class:")[1].lstrip.rstrip
  elsif line.include?("Superclass:")
  	superclass = line.split("Superclass:")[1].lstrip.rstrip
   end
}

header_license = nil
File.open("header_license", 'r') { |file|
	header_license = file.read()
}
header_license.gsub!("___COPYRIGHT___", copyright)
header_license.gsub!("___DEVELOPER___",developer)
header_license.gsub!("___DATE___",formatted_date)
header_license.gsub!("___CLASS___", new_class)
header_license.gsub!("___PROJECT___", project)
header_license.gsub!("___YEAR___", date.year.to_s)

puts header_license

implementation_license = nil
File.open("implementation_license", 'r') { |file|
	implementation_license = file.read()
}
implementation_license.gsub!("___COPYRIGHT___", copyright)
implementation_license.gsub!("___DEVELOPER___",developer)
implementation_license.gsub!("___DATE___",formatted_date)
implementation_license.gsub!("___CLASS___", new_class)
implementation_license.gsub!("___PROJECT___", project)
implementation_license.gsub!("___YEAR___", date.year.to_s)

puts implementation_license

contents = nil
File.open("demo", 'r') { |file|
contents = file.read()
}
bools = Array.new()
doubles = Array.new()
floats = Array.new()
ints = Array.new()
integers = Array.new()
int32s = Array.new()
int64s = Array.new()
objects = Array.new()
full_objects = Array.new()
def parseLineIntoArray(line, array)
	components = line.split(",")
	components.each_index { |i|
		if i > 0 && !components[i].lstrip.empty?
			array << components[i].lstrip.rstrip
		else
			array.clear
		end 
	}
end

def parseObjectsIntoArray(line, array, full_array)
	components = line.split(",")
	components.each_index { |i|
		if i > 0 && !components[i].empty?
			more_components = components[i].split("*")
			full_array << components[i].lstrip.rstrip
			array << more_components[1].lstrip.rstrip
		end 
	}
end
def parseEncodeDecodeForBools(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeBool:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeBoolForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForDoubles(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeDouble:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeDoubleForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForFloats(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeFloat:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeFloatForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForInts(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeInt:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeIntForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForIntegers(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeInteger:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeIntegerForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForInt32s(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeInt32:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeInt32ForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForInt64s(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeInt64:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\t#{var} = [aDecoder decodeInt64ForKey:@\"#{var}\"];\n"
	}
end
def parseEncodeDecodeForObjects(encode_body,decode_body,vars)
	vars.each { |var|
		encode_body << "\t[aCoder encodeObject:#{var} forKey:@\"#{var}\"];\n"
		decode_body << "\tself.#{var} = [aDecoder decodeObjectForKey:@\"#{var}\"];\n"
	}
end


contents.each_line { |line| 
	components = line.split(",")
	if (components[0].lstrip.rstrip <=> "BOOL") == 0
		parseLineIntoArray(line, bools)
	elsif (components[0].lstrip.rstrip <=> "double") == 0
		parseLineIntoArray(line, doubles)
	elsif (components[0].lstrip.rstrip <=> "float") == 0
		parseLineIntoArray(line, floats)
	elsif (components[0].lstrip.rstrip <=> "int") == 0
		parseLineIntoArray(line, ints)
	elsif (components[0].lstrip.rstrip <=> "NSInteger") == 0
		parseLineIntoArray(line, integers)
	elsif (components[0].lstrip.rstrip <=> "int32_t") == 0
		parseLineIntoArray(line, int32s)
	elsif (components[0].lstrip.rstrip <=> "int64_t") == 0
		parseLineIntoArray(line, int64s)
	elsif (components[0].lstrip.rstrip <=> "id") == 0
		parseObjectsIntoArray(line, objects, full_objects)
	end
}

h_filename = "#{new_class}.h"
File.open(h_filename,'w') { |file| 
  file.write(header_license)
  file.write("#import <UIKit/UIKit.h>\n\n")
  file.write("@interface #{new_class} : #{superclass} <NSCoding>\n")
  bools.each { |bool|
  	file.write("@property BOOL #{bool};\n")
  }
  doubles.each { |double|
  	file.write("@property double #{double};\n")
  }
  floats.each { |float|
  	file.write("@property float #{float};\n")
  }
  ints.each { |int|
  	file.write("@property int #{int};\n")
  }
  integers.each { |integer|
  	file.write("@property NSInteger #{integer};\n")
  }
  int32s.each { |i32|
  	file.write("@property int32_t #{i32};\n")
  }
  int64s.each { |i64|
  	file.write("@property int64_t #{i64};\n")
  }
  full_objects.each { |object|
  	file.write("@property (nonatomic, strong) #{object};\n")
  }
  file.write("@end")
}
m_filename = "#{new_class}.m"
encode_body = ""
decode_body = ""
parseEncodeDecodeForBools(encode_body,decode_body,bools)
parseEncodeDecodeForDoubles(encode_body,decode_body,doubles)
parseEncodeDecodeForFloats(encode_body,decode_body,floats)
parseEncodeDecodeForInts(encode_body,decode_body,ints)
parseEncodeDecodeForIntegers(encode_body,decode_body,integers)
parseEncodeDecodeForInt32s(encode_body,decode_body,int32s)
parseEncodeDecodeForInt64s(encode_body,decode_body,int64s)
parseEncodeDecodeForObjects(encode_body,decode_body,objects)
puts encode_body + "\n" + decode_body
File.open(m_filename,'w') { |file|
	file.write(implementation_license)
	file.write("#import \"#{new_class}.h\"\n\n")
	file.write("@implementation #{new_class}\n\n")
	file.write("- (void)encodeWithCoder:(NSCoder *)aCoder\n")
	file.write("{\n")
	file.write(encode_body)
	file.write("}\n\n")
	file.write("- (id)initWithCoder:(NSCoder *)aDecoder\n")
	file.write("{\n")
	file.write(decode_body)
	file.write("}\n\n")
	file.write("@end")
}