class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource

  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.all
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
  end

  # # GET /courses/new
  # def new
  #   @course = Course.new
  # end

  # GET /courses/1/edit
  def edit
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        @course.accept_invite_to_course_org
        format.html { redirect_to @course, notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /courses/1
  # PATCH/PUT /courses/1.json
  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def join
    course = Course.find(params[:course_id])

    roster_student = course.roster_students.find_by(email: current_user.email)
    if not roster_student.nil?
      current_user.roster_students.push(roster_student)
      redirect_to courses_path, notice: %Q[You were successfully enrolled in #{course.name}! View you invitation <a href="https://github.com/orgs/#{course.course_organization}/invitation">here</a>.]
      course.invite_user_to_course_org(current_user)
    else
      message = 'Your email did not match the email of any student on the course roster. Please check that your github email is correctly configured to match your school email and that you have verrified your email address. '
      redirect_to courses_path, alert: message
    end
  end

  def leave
    roster_student = Course.find(params[:course_id]).roster_students.find_by(email: current_user.email)
    roster_student.update_attribute(:user_id, nil)
    redirect_to courses_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course
      @course = Course.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def course_params
      params.require(:course).permit(:name,:course_organization)
    end
end
