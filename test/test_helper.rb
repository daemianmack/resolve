ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  
  include AuthenticatedTestHelper

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  module CategoryTestHelper
    def valid_category_attributes
      {:name => "Coupon Codes"}
    end

    protected
      def create_category
        @category = Category.new
      end
  end  

  module CommentTestHelper
    def valid_post_attributes
      {:content => "<p>Il parlar auxiliar ascoltar uso, ille addresses del in, tu pro nomina latente anteriormente. Sitos conferentias non da. Es uno prime deler linguistas, da sine personas auxiliar uno, laborava summarios nos un. In spatios medical publicate per, pan su anque auxiliary anteriormente. In pan proposito sanctificate, duo moderne ascoltar secundarimente un. Qui libere denomination in.</p>
  <p>Titulo giuseppe primarimente ma uso, libro continentes via se. Inviar nostre linguas de via. Es ille brevissime methodicamente sed, sia un quales romanic paternoster. De per medio africa tamben.</p>",  :user_id => 1}
    end

    protected
      def create_comment
        @comment = Comment.new
      end
  end

  module ItemTestHelper
    def valid_item_attributes
      {:name => "Coupon codes needed for Carnegie Hall", :priority => 3, :description => "Lorem ipsum dolor sit amet", :wanted_on => 1.day.from_now, :dropdead_on => 3.days.from_now, :requester_id => 1, :fixer_id => 2, :lock_version => 1}
    end

    protected
      def create_item
        @item = Item.new
        @item.requester_id = 1
      end
  end

  module PostTestHelper
    def valid_post_attributes
      {:content => "<p>Il parlar auxiliar ascoltar uso, ille addresses del in, tu pro nomina latente anteriormente. Sitos conferentias non da. Es uno prime deler linguistas, da sine personas auxiliar uno, laborava summarios nos un. In spatios medical publicate per, pan su anque auxiliary anteriormente. In pan proposito sanctificate, duo moderne ascoltar secundarimente un. Qui libere denomination in.</p>
  <p>Titulo giuseppe primarimente ma uso, libro continentes via se. Inviar nostre linguas de via. Es ille brevissime methodicamente sed, sia un quales romanic paternoster. De per medio africa tamben.</p>",  :user_id => 1}
    end

    protected
      def create_post
        @post = Post.new
      end
  end

  module UserTestHelper
    def valid_user_attributes
      {:login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire'}
    end

    protected
      def create_user
        @user = User.new
      end
  end
end
