# This class is used to store images of
# renters on the filesystem. PAth to images
# is stored in DB.
require 'mini_magick'
 
class Picture
 
  attr_accessor :id, :file
 
  def initialize(id,file)
    @id = id
    @file = file
    @filename =  base_part_of(file.original_filename)
    @content_type = file.content_type.chomp  
  end

  def base_part_of(file_name)
    name = File.basename(file_name)
    name.gsub(/[^\w._-]/, '')
  end 
  
  def save
   is_saved = false
   begin
     if @file
       #using @id, find the id of the User, then use the id to create the title
       if @content_type =~ /^image/
       #instead of product = Product.find, you can say dog = Dog.find or whatever corresponds to your model.
       current_renter = Renter.find(@id.to_i)
       #Make the directory for the id
       Dir.mkdir("#{RAILS_ROOT}/public/images/renters/#{@id}") unless File.exist?("#{RAILS_ROOT}/public/images/renters/#{@id}")
       #Then create the temp file
       File.open("#{RAILS_ROOT}/public/images/renters/#{@id}/#{@filename}", "wb") do |f|
        f.write(@file.read)
       end
       renter_image_crop("#{@filename}")
       #update the current renter
       image_names = renter_image_names("#{@filename}")
       File.open("#{RAILS_ROOT}/public/yo.txt", "wb") do |f|
         f.write(image_names)
       end
       current_renter.update_attributes("image_square" => image_names[0], "image_small" => image_names[1], "image_medium" => image_names[2], "image_original" => image_names[3])
         is_saved = true
         end
      end
#    rescue
     end
     return is_saved
   end

  def renter_image_crop(renter_image_title)
  
    #renter_title = renter_title.squeeze.gsub(" ","_").downcase
    #find the extension for this file
    image_file_extension = renter_image_title[renter_image_title.rindex(".") .. renter_image_title.length].strip.chomp
    image = MiniMagick::Image.from_file("#{RAILS_ROOT}/public/images/renters/#{@id}/#{renter_image_title}")
    
    image.resize "400X300"
    image.write("#{RAILS_ROOT}/public/images/renters/#{@id}/#{@id}_medium#{image_file_extension}")  
     
    image.resize "240X180"
    image.write("#{RAILS_ROOT}/public/images/renters/#{@id}/#{@id}_small#{image_file_extension}")  
    
    image.resize "50X50"
    image.write("#{RAILS_ROOT}/public/images/renters/#{@id}/#{@id}_square#{image_file_extension}")
    
    #Finally, rename the originally uploaded image
    File.rename("#{RAILS_ROOT}/public/images/renters/#{@id}/#{renter_image_title}", "#{RAILS_ROOT}/public/images/renters/#{@id}/#{@id}_original#{image_file_extension}")
   
  end
    
  def renter_image_names(renter_image_title)
    image_file_extension = renter_image_title[renter_image_title.rindex(".") .. renter_image_title.length].strip.chomp
    #Generate an array containing the url of all the images
    ["/images/renters/#{@id}/#{@id}_square#{image_file_extension}",  "/images/renters/#{@id}/#{@id}_small#{image_file_extension}","/images/renters/#{@id}/#{@id}_medium#{image_file_extension}",  "/images/renters/#{@id}/#{@id}_original#{image_file_extension}"]
  end
    
 end