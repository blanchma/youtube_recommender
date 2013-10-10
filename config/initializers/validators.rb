

class StopwordFilterValidator < ActiveModel::EachValidator
  # implement the method called during validation
  def validate_each(record, attribute, value)
    record.errors[attribute] << 'cant be a stopword' if Stopwords.is?(value)
  end
end
