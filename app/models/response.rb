class Response < ActiveRecord::Base

  # Extending surveyor
  include "#{self.name}Extensions".constantize if Surveyor::Config['extend'].include?(self.name.underscore)
  
  include ActionView::Helpers::SanitizeHelper
         
  # Associations
  belongs_to :response_set
  belongs_to :question
  belongs_to :answer
  
  # Validations
  validates_presence_of :response_set_id, :question_id, :answer_id
      
  acts_as_response # includes "as" instance method

  def selected
    !self.new_record?
  end
  
  alias_method :selected?, :selected
  
  def selected=(value)
    true
  end
  
  def correct?
    question.correct_answer_id.nil? or self.answer.response_class != "answer" or (question.correct_answer_id.to_i == answer_id.to_i)
  end
  
  def to_s # used in dependency_explanation_helper
    if self.answer.response_class == "answer" and self.answer_id
      return self.answer.text
    else
      return "#{(self.string_value || self.text_value || self.integer_value || self.float_value || nil).to_s}"
    end
  end
  

		#	Error for when answer's response_class is not in
		#	( answer string integer float text date time datetime )
		#	Actually, date and time aren't available anymore.
		class InvalidResponseClass < StandardError	#:nodoc:
		end

		#	Return an individual response's question and
		#	answer coded for Home Exposure questionnaire.
		def q_and_a_codes
			q_code = self.question.data_export_identifier

			unless %w( answer string integer float
					text datetime
				).include?(self.answer.response_class)
				raise InvalidResponseClass
			end

			a_code = if self.answer.response_class == "answer"
				self.answer.data_export_identifier
			else
				self.send("#{self.answer.response_class}_value")
			end
			[ q_code, a_code ]
		end

		def q_and_a_codes_and_text
			q_code = self.question.data_export_identifier

			unless %w( answer string integer float
					text datetime
				).include?(self.answer.response_class)
				raise InvalidResponseClass
			end

			a_code = if self.answer.response_class == "answer"
				self.answer.data_export_identifier
			else
				self.send("#{self.answer.response_class}_value")
			end

			a_text = if self.answer.response_class == "answer"
				self.answer.text
			else
				self.send("#{self.answer.response_class}_value")
			end

			q_text = self.question.text

			{ q_code => { :a_code => a_code, :a_text => a_text, :q_text => q_text }}
		end
		alias_method :codes_and_text, :q_and_a_codes_and_text
		

end
