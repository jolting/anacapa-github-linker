require 'test_helper'

class RosterStudentsControllerTest < ActionDispatch::IntegrationTest

  include Devise::Test::IntegrationHelpers

  setup do
    @course = courses(:course1)
    @course2 = courses(:course2)
    @roster_student = roster_students(:roster1)
    @user = users(:wes)
    @user.add_role(:admin)
    sign_in @user
  end

  test "should get new" do
    get new_course_roster_student_path(:course_id=> @course.id)
    assert_response :success
  end

  test "should create roster_student" do
    assert_difference('RosterStudent.count',1) do
      post course_roster_students_path(
        course_id: @course.id,
        params: {
          roster_student: {
            email: "email@test.email.com",
            first_name: "Jon",
            last_name: "Snow",
            perm: 1337888
          }
        }
      )
    end

    assert_redirected_to course_path(@course)
  end

  test "should not be able to create nonunique roster student(perm, courseid)" do
    assert_difference('RosterStudent.count',0) do
      post course_roster_students_path(
        course_id: @course.id,
        params: {
          roster_student: {
            email: "email@test.email.com",
            first_name: "Jon",
            last_name: "Snow",
            perm: @roster_student.perm
          }
        }
      )
    end
  end
  
  test "should not be able to create nonunique roster student(email, courseid)" do
    assert_difference('RosterStudent.count',0) do
      post course_roster_students_path(
        course_id: @course.id,
        params: {
          roster_student: {
            email: @roster_student.email,
            first_name: "Jon",
            last_name: "Snow",
            perm: 1234567
          }
        }
      )
    end
  end

  test "should show roster_student" do
    get course_roster_student_path(:course_id=> @roster_student.course_id, :id=> @roster_student.id)
    assert_response :success
  end

  test "should get edit" do
    get edit_course_roster_student_path(:course_id=> @roster_student.course_id, :id=> @roster_student.id)
    assert_response :success
  end

  test "should update roster_student" do
    patch course_roster_student_path(
      :course_id=> @roster_student.course_id,
      :id=> @roster_student.id,
      params: {
        roster_student: {
          email: @roster_student.email,
          first_name: @roster_student.first_name,
          last_name: @roster_student.last_name,
          perm: @roster_student.perm
        }
      }
    )
    assert_redirected_to course_path(@roster_student.course_id)
  end

  test "should destroy roster_student" do
    assert_difference('RosterStudent.count', -1) do
      delete course_roster_student_path(@roster_student.course_id, @roster_student.id)
    end

    assert_redirected_to course_path(@roster_student.course_id)
  end

  test "an instructor should be able to create a roster student for his class" do
    user = users(:tim)
    user.add_role(:user)
    user.add_role(:instructor)
    user.add_role(:instructor, @course)
    sign_in user

    assert_difference('RosterStudent.count',1) do
      post course_roster_students_path(
        course_id: @course.id,
        params: {
          roster_student: {
            email: "email@test.email.com",
            first_name: "Jon",
            last_name: "Snow",
            perm: 1337888
          }
        }
      )
    end

    assert_redirected_to course_path(@course)


  end

  test "Instructors should be able to destroy their own roster students" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :instructor
    @user.add_role :instructor, @course
    sign_in @user

    assert_difference('RosterStudent.count', -1) do
      delete course_roster_student_path(@roster_student.course_id, @roster_student.id)
    end

    assert_redirected_to course_path(@roster_student.course_id)
  end

  test "Instructors should not be able to destroy other course's roster students" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :instructor
    @user.add_role :instructor, @course2
    sign_in @user

    assert_difference('RosterStudent.count', 0) do
      delete course_roster_student_path(@roster_student.course_id, @roster_student.id)
    end

    assert_redirected_to root_url
  end

  test "TAs should be able to create new roster_students" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :ta, @course
    sign_in @user

    assert_difference('RosterStudent.count', 1) do
      post course_roster_students_path(
          course_id: @course.id,
          params: {
            roster_student: {
              email: "email@test.email.com",
              first_name: "Jon",
              last_name: "Snow",
              perm: 293847823795
            }
          }
        )
    end
    assert_redirected_to  course_path(@roster_student.course_id)
  end

  test "TAs should be able to update their own roster_students" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :ta, @course
    sign_in @user

    patch course_roster_student_path(
      :course_id=> @roster_student.course_id,
      :id=> @roster_student.id,
      params: {
        roster_student: {
          email: @roster_student.email,
          first_name: @roster_student.first_name,
          last_name: @roster_student.last_name,
          perm: @roster_student.perm
        }
      }
    )
    assert_redirected_to course_path(@roster_student.course_id)
  end

  test "a TA of one class cannot update roster student for a different class" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :ta, @course
    @user.add_role :instructor
    @user.add_role :instructor, @course
    sign_in @user

    
    assert_difference('RosterStudent.count',0) do
      post course_roster_students_path(
        course_id: @course2.id,
        params: {
          roster_student: {
            email: "email@test.email.com",
            first_name: "Jon",
            last_name: "Snow",
            perm: 3278923752
          }
        }
      )
    end

    assert_redirected_to root_url
  end


  test "TAs should be not be able to update other course's roster_students" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :ta, @courrse
    sign_in @user

    patch course_roster_student_path(
      :course_id=> @roster_student.course_id,
      :id=> @roster_student.id,
      params: {
        roster_student: {
          email: @roster_student.email,
          first_name: @roster_student.first_name,
          last_name: @roster_student.last_name,
          perm: @roster_student.perm
        }
      }
    )
    assert_redirected_to root_url
  end

  test "TAs should not be allowed to delete roster_students" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :ta, @course
    sign_in @user

    assert_difference('RosterStudent.count', 0) do
      delete course_roster_student_path(@roster_student.course_id, @roster_student.id)
    end

    assert_redirected_to root_url
  end

  test "An instructor of one course should not have instructor privileges if he is TA of a different course" do
    @user = users(:julie)
    @user.add_role :user
    @user.add_role :ta, @course
    @user.add_role :instructor
    @user.add_role :instructor, @course2
    sign_in @user

    assert_difference('RosterStudent.count', 0) do
      delete course_roster_student_path(@roster_student.course_id, @roster_student.id)
    end

    assert_redirected_to root_url
  end
end
