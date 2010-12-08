class Survey < ActiveRecord::Base

  # Extending surveyor
  include "#{self.name}Extensions".constantize if Surveyor::Config['extend'].include?(self.name.underscore)

  # Associations
  has_many :sections, :class_name => "SurveySection", :order => 'display_order'
  has_many :sections_with_questions, :include => :questions, :class_name => "SurveySection", :order => 'display_order'
  has_many :response_sets
  has_many :questions, :through => :sections
  
  # Scopes
  named_scope :with_sections, {:include => :sections}
  
  # Validations
  validates_presence_of :title
  validates_uniqueness_of :access_code
  
  # Class methods
  def self.to_normalized_string(value)
    # replace non-alphanumeric with "-". remove repeat "-"s. don't start or end with "-"
    value.to_s.downcase.gsub(/[^a-z0-9]/,"-").gsub(/-+/,"-").gsub(/-$|^-/,"")
  end
  
  # Instance methods
  def initialize(*args)
    super(*args)
    default_args
  end
  
  def default_args
    self.inactive_at ||= DateTime.now
  end
  
  def title=(value)
    self.access_code = Survey.to_normalized_string(value)
    super
  end
  
  def active?
    self.active_as_of?(DateTime.now)
  end
  def active_as_of?(datetime)
    (self.active_at.nil? or self.active_at < datetime) and (self.inactive_at.nil? or self.inactive_at > datetime)
  end  
  def activate!
    self.active_at = DateTime.now
  end
  def deactivate!
    self.inactive_at = DateTime.now
  end
  def active_at=(datetime)
    self.inactive_at = nil if !datetime.nil? and !self.inactive_at.nil? and self.inactive_at < datetime
    super(datetime)
  end
  def inactive_at=(datetime)
    self.active_at = nil if !datetime.nil? and !self.active_at.nil? and self.active_at > datetime
    super(datetime)
  end



		#	Survey access_code not guaranteed to be unique
		#
		#	As there is no model validation or unique index in the 
		#	database, there is no guarantee that your survey access_code 
		#	will be unique.  It is just a normalized version of your 
		#	survey title.  
		#
		#	Running ...
		#
		#		rake surveyor FILE=surveys/kitchen_sink_survey.rb APPEND=true
		#		rake surveyor FILE=surveys/kitchen_sink_survey.rb APPEND=true
		#		script/console
		#		Survey.all.collect(&:access_code)
		#
		#	should show this to be true.
		#
		#	This will show both surveys as able to be taken, but will 
		#	only allow the first one when the attempt is made as the 
		#	survey is found by
		#
		#
		#		@survey = Survey.find_by_access_code(params[:survey_code])
		#
		#
		#	In addition, adding a unique index to the db and model will 
		#	make a mess when running 
		#
		#		rake surveyor FILE=surveys/kitchen_sink_survey.rb APPEND=true
		#		rake surveyor FILE=surveys/kitchen_sink_survey.rb APPEND=true
		#
		#	as the access_code is not unique and the survey fixtures are 
		#	loaded last, leaving the associations with an invalid survey_id.  
		#	To avoid this, the survey fixture should probably be attempted first.
		#
		#
		#	Update...
		#
		#	Adding something like ...
		#
		#		def access_code=(value)
		#			counter = 2
		#			original_value = value
		#			while( ( survey = Survey.find_by_access_code(value) ) && 
		#				( self.id != survey.id ) )
		#				value = [original_value,"_",counter].join
		#				counter += 1
		#			end
		#			super
		#		end
		#
		#	... to Survey seems to provide a "fix" for this "problem", 
		#	although I don't know how kosher it is.
		#
		#	It works in my test environment, but does not actually work 
		#	in the "rake surveyor" task as the survey is built from a 
		#	different Survey model completely and then loaded into the 
		#	database and not created though the application.
		#
		#	My final "fix" was to add 
		#
		#		require 'lib/surveyor/survey_extensions'
		#
		#	to my Rakefile and create the file
		#
		#	> cat lib/surveyor/survey_extensions.rb
		#		if surveyor_gem = Gem.searcher.find('surveyor')
		#			require surveyor_gem.full_gem_path + '/script/surveyor/parser'
		#			require surveyor_gem.full_gem_path + '/script/surveyor/survey'
		#		end
		#
		#		module SurveyParser
		#		module SurveyExtensions
		#		  def self.included(base)
		#		    base.class_eval do
		#		      def initialize_with_unique_access_code(obj, args, opts)
		#		        initialize_without_unique_access_code(obj, args, opts)
		#		        counter = 2
		#		        ac = self.access_code
		#		        original_ac = self.access_code
		#		        while( survey = ::Survey.find_by_access_code(ac) ) 
		#		          ac = [original_ac,"_",counter].join
		#		          counter += 1
		#		        end
		#		        self.access_code = ac
		#		      end
		#		      alias_method_chain :initialize, :unique_access_code
		#		    end
		#		  end
		#		end
		#		end
		#		SurveyParser::Survey.send(:include, SurveyParser::SurveyExtensions)
		#
		#	It is not as clean as I would've liked, but works.
		#	Override the setting of the access_code to ensure its uniqueness
		#
		#	While uniqueness was added after 0.10.0, this method
		#	was not deemed important or likely to be needed enough.
		#	It is true that this really isn't NEEDed.
		def access_code=(value)
			counter = 2
			original_value = value
			while( ( survey = Survey.find_by_access_code(value) ) && 
				( self.id != survey.id ) )
				value = [original_value,"_",counter].join
				counter += 1
			end
			super		#(value)
		end
  
end
