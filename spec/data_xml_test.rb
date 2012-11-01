require File.expand_path(File.dirname(__FILE__)+ '/test_helper')

include GData

describe "GData XML test" do

  def generate_base_descendant_class(&block)
    klass = Class.new(Atom::Base)
    klass.instance_eval &block if block_given?
    klass
  end

  describe "Klass derived from Atom::Base" do
    
    before :each do
      Object.const_set(:Klass, generate_base_descendant_class)
      Object.const_set(:ItemKlass, generate_base_descendant_class)
    end
    
    after :each do
      Object.send(:remove_const, :Klass)
      Object.send(:remove_const, :ItemKlass)
    end
    
    describe "class having 'singular' element" do
      before :each do
        Klass.instance_eval do
          elements 'singular' 
        end
        @instance = Klass.new
      end
      
      it "should have getter/setter  methods for element :singular => 'singnular'" do
        @instance.should respond_to :singular
        @instance.should respond_to(:singular=)
        expect {@instance.singular?}.to raise_error(NoMethodError)
        expect {@instance.singulars}.to raise_error(NoMethodError)
      end
      
      it "should accept String for setter and return it from getter" do
        expect{@instance.singular = "value"}.to_not raise_error
        @instance.singular.should == "value"
      end
      
      it "should raise on getting non existing element" do
        expect {@instance.not_existing_method}.to raise_error(NoMethodError)
      end
      
      it "should have default value as ''" do
        @instance.singular.should == ""
      end
    end

    describe "class having 'optional?' element" do
      before :each do
        Klass.instance_eval do
          elements 'optional?' 
        end
        @instance = Klass.new
      end
      
      it "should have getter/setter methods for element :optional => 'optional?'" do
        @instance.should respond_to :optional
        @instance.should respond_to :optional=
        @instance.should respond_to :optional?
        expect {@instance.optionals}.to raise_error(NoMethodError)
      end
      
      it "should accept String for setter and return it from getter" do
        expect {@instance.optional = "value"}.to_not raise_error
        @instance.optional.should == "value"
      end
      
      it "should raise on getting non existing element" do
        expect {@instance.not_existing_method}.to raise_error(NoMethodError)
      end
      
      it "should have default value nil" do
        @instance.optional?.should_not be_true
        @instance.optional.should be_nil
      end
    end

    describe "class having 'many*' element" do
      before :each do
        Klass.instance_eval do
          elements 'atom:many*'
        end
        @instance = Klass.new
      end
      
      it "should not generate setter methods for element :many => 'many*'" do
        @instance.should respond_to(:many)
        expect {@instance.many=""}.to raise_error(NoMethodError)
      end
      
      it "should raise on getting non existing element" do
        expect {@instance.not_existing_method}.to raise_error(NoMethodError)
        expect {@instance.many?}.to raise_error(NoMethodError)
      end
      
      it "should have default value of empty Array" do
        @instance.many.should == []
      end

      it "should generate correct xml when acts as container for String items" do
        @instance.many.push("first")
        @instance.many.push("second")
        @instance.many.size.should == 2
        debugger
        xml = Nokogiri::XML(@instance.to_xml("atom:klass"))
        xml.xpath("/atom:klass/atom:many").size.should == 2
      end
      
      it "should generate correct xml when acts as container for ItemKlass items" do
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
        @instance.few.size.should == 2
        xml = Nokogiri::XML(@instance.to_xml("atom:klass"))
        xml.xpath("/atom:klass/atom:few").size.should == 2
        xml.xpath("/atom:klass/atom:few/@name").size.should == 2
      end
    end
    
    describe "class having 'atom:singular' element" do
      before :each do
        Klass.instance_eval do
          elements 'atom:singular', 'text()'
        end
        @instance = Klass.new
      end
      
      it "should have 'singular' method" do
        @instance.should respond_to(:singular)
      end
      
      it "should have 'text' method" do
        @instance.should respond_to(:text)
      end
      
      it "should correctly generate xml" do
        @instance.singular = "Singular"
        @instance.text = "text"
        xml = @instance.to_xml("atom:klass")
        xml = Nokogiri::XML(xml)
        xml.xpath("/atom:klass/atom:singular").size.should == 1
        xml.xpath("/atom:klass/text()").to_s.should == "text"
      end
      
      it "should correctly converted to and from hash" do
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
        hash["item"]["when"].should == now.to_s

        #classes stored as string to save them in db
        hash["item"]["class"].should == "ItemKlass"
        new_instance = Atom::Base.from_hash(hash)
        new_instance.singular.should == @instance.singular
        new_instance.text.should == @instance.text
        new_instance.item.when.should == @instance.item.when
        new_instance.item.when.should == now
      end
    end
  end
end
