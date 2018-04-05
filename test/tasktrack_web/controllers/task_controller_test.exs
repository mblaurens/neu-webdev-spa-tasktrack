defmodule TasktrackWeb.TaskControllerTest do
  use TasktrackWeb.ConnCase

  alias Tasktrack.Tasks
  alias Tasktrack.Tasks.Task

  @create_attrs %{act_time: 42, completed: true, desc: "some desc", title: "some title"}
  @update_attrs %{act_time: 43, completed: false, desc: "some updated desc", title: "some updated title"}
  @invalid_attrs %{act_time: nil, completed: nil, desc: nil, title: nil}

  def fixture(:task) do
    {:ok, task} = Tasks.create_task(@create_attrs)
    task
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tasks", %{conn: conn} do
      conn = get conn, task_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create task" do
    test "renders task when data is valid", %{conn: conn} do
      conn = post conn, task_path(conn, :create), task: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, task_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "act_time" => 42,
        "completed" => true,
        "desc" => "some desc",
        "title" => "some title"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, task_path(conn, :create), task: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update task" do
    setup [:create_task]

    test "renders task when data is valid", %{conn: conn, task: %Task{id: id} = task} do
      conn = put conn, task_path(conn, :update, task), task: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, task_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "act_time" => 43,
        "completed" => false,
        "desc" => "some updated desc",
        "title" => "some updated title"}
    end

    test "renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put conn, task_path(conn, :update, task), task: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete task" do
    setup [:create_task]

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete conn, task_path(conn, :delete, task)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, task_path(conn, :show, task)
      end
    end
  end

  defp create_task(_) do
    task = fixture(:task)
    {:ok, task: task}
  end
end
