require File.expand_path('../../test_helper', __FILE__)

class UsersFieldFromToTest < ActiveSupport::TestCase

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_default_value_mast_be
    users_field_from_to = UsersFieldFromTo.new
    users_field_from_to.fields_from_to
    users_field_from_to.hot_button_id  = 1
    users_field_from_to.save

    assert_equal JSON.parse("{}"), users_field_from_to.fields_from_to
  end

  def test_must_be_json
    users_field_from_to = UsersFieldFromTo.new
    users_field_from_to.fields_from_to
    users_field_from_to.hot_button_id  = 1
    users_field_from_to.save

    assert_instance_of Hash, users_field_from_to.fields_from_to
  end
end
