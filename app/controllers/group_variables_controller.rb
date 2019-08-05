
class GroupVariablesController < VariablesController
  before_action :authenticate_admin_or_instructor!

  def index
    @variables = group.variable_templates
  end

  def new
    @variable = VariableTemplate.new
    @variable.group = group
  end

  def create
    @variable = VariableTemplate.new(variable_params)
    if @variable.valid? then
      @variable.save!
      flash[:notice] = "Variable '#{@variable.name}' Added"
      redirect_to users_scenario_path(@variable.group.scenario)
    else
      render :new
    end
  end

  private

  def group
    @group ||= Group.find(params.require(:group_id))
  end

  before_action do
    @user = current_user
    @scenario = group.scenario
  end

end
