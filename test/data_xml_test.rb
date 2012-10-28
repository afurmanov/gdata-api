require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

include GData

class GDataXmlTest < Test::Unit::TestCase
  def self.generate_base_descendant_class(&block)
    klass = Class.new(Atom::Base)
    klass.instance_eval &block if block_given?
    klass
  end
  
  context "Klass derived from Atom::Base" do
    setup do
      self.class.const_set(:Klass, GDataXmlTest.generate_base_descendant_class)
      self.class.const_set(:ItemKlass, GDataXmlTest.generate_base_descendant_class)
    end
    
    teardown do
      self.class.send(:remove_const, :Klass)
      self.class.send(:remove_const, :ItemKlass)
    end
    
    context "class having 'singular' element" do
      setup do
        Klass.instance_eval do
          elements 'singular' 
        end
        @instance = Klass.new
      end
      
      should "have getter/setter  methods for element :singular => 'singnular'" do
        assert_respond_to @instance, :singular
        assert_respond_to @instance, :singular=
        assert_raise NoMethodError do @instance.singular? end
        assert_raise NoMethodError do @instance.singulars end
      end
      
      should "accept String for setter and return it from getter" do
        @instance.singular = "value"
        assert_equal String, @instance.singular.class
        assert_equal "value", @instance.singular
      end
      
      should "raise on getting non existing element" do
        assert_raise NoMethodError do @instance.not_existing_method end
      end
      
      should "have default value as ''" do
        assert_equal "", @instance.singular
      end
    end

    context "class having 'optional?' element" do
      setup do
        Klass.instance_eval do
          elements 'optional?' 
        end
        @instance = Klass.new
      end
      
      should "have getter/setter methods for element :optional => 'optional?'" do
        assert_respond_to @instance, :optional
        assert_respond_to @instance, :optional=
        assert_respond_to @instance, :optional?
        assert_raise NoMethodError do @instance.optionals end
      end
      
      should "accept String for setter and return it from getter" do
        @instance.optional = "value"
        assert_equal String, @instance.optional.class
        assert_equal "value", @instance.optional
      end
      
      should "raise on getting non existing element" do
        assert_raise NoMethodError do @instance.not_existing_method end
      end
      
      should "have default value nil" do
        assert !@instance.optional?
        assert_equal nil, @instance.optional
      end
    end

    context "class having 'many*' element" do
      setup do
        Klass.instance_eval do
          elements 'atom:many*'
        end
        @instance = Klass.new
      end
      
      should "generate getter/setter methods for element :many => 'many*'" do
        assert_respond_to @instance, :many
        assert_raise NoMethodError do @instance.many="" end
        assert_raise NoMethodError do @instance.many? end
      end
      
      should "raise on getting non existing element" do
        assert_raise NoMethodError do @instance.not_existing_method end
      end
      
      should "have default value Array" do
        assert_equal Array, @instance.many.class
      end

      should "generate correct xml when acts as container for String items" do
        @instance.many.push("first")
        @instance.many.push("second")
        assert_equal 2, @instance.many.size
        xml = Nokogiri::XML(@instance.to_xml("atom:klass"))
        assert_equal 2, xml.xpath("/atom:klass/atom:many").size
      end
      
      should "generate correct xml when acts as container for ItemKlass items" do
        Klass.instance_eval do
          elements 'atom:few*' => ItemKlass
        end
        ItemKlass.instance_eval do
          elements '@name'
        end
        item1 = ItemKlass.new
        item1.name = "first"
        item2 = ItemKlass.new
        item2.name = "second"
        @instance.few.push(item1)
        @instance.few.push(item2)
        assert_equal 2, @instance.few.size
        xml = Nokogiri::XML(@instance.to_xml("atom:klass"))
        assert_equal 2, xml.xpath("/atom:klass/atom:few").size
        assert_equal 2, xml.xpath("/atom:klass/atom:few/@name").size
      end
    end
    
    context "class having 'atom:singular' element" do
      setup do
        Klass.instance_eval do
          elements 'atom:singular', 'text()'
        end
        @instance = Klass.new
      end
      should "have 'singular' method" do
        assert_respond_to @instance, :singular
      end
      should "have 'text' method" do
        assert_respond_to @instance, :text
      end
      
      should "correctly generate xml" do
        @instance.singular = "Singular"
        @instance.text = "text"
        xml = @instance.to_xml("atom:klass")
        xml = Nokogiri::XML(xml)
        assert_equal 1, xml.xpath("/atom:klass/atom:singular").size
        assert_equal "text", xml.xpath("/atom:klass/text()").to_s
      end
      
      should "correctly converted to and from hash" do
        @instance.singular = "Singular"
        @instance.text = "text"
        Klass.instance_eval do 
          elements 'atom:item' => ItemKlass
        end
        ItemKlass.instance_eval do
          elements '@when' => DateTime
        end
        item = ItemKlass.new
        now = DateTime.new
        item.when = now
        @instance.item = item
        hash = @instance.to_hash
        assert_equal(now.to_s, hash["item"]["when"])
        #classes stored as string to save them in db
        assert_equal("#{self.class}::ItemKlass", hash["item"]["class"])
        new_instance = Atom::Base.from_hash(hash)
        assert_equal(@instance.singular, new_instance.singular)
        assert_equal(@instance.text, new_instance.text)
        assert_equal(@instance.item.when, new_instance.item.when)
        assert_equal(now, new_instance.item.when)
      end
     end
  end
end
