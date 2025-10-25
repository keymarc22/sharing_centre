class DashboardController < ApplicationController
  def index
    # @current_user = current_user_data
    # @classes = classes_data
    # @lessons = lessons_data
    # @reminders = reminders_data
    # @calendar_date = Date.new(2022, 12, 1)

    render Views::Dashboard::Index.new
  end

  private

  def current_user_data
    {
      name: "Stella Walton",
      role: "Student",
      avatar: "SW"
    }
  end

  def classes_data
    [
      {
        title: "English - UNIT III",
        files: 10,
        teacher: "Leona Jimenez",
        color: "bg-blue-500",
        avatars: ["LC", "MJ", "SK"]
      },
      {
        title: "English - UNIT II",
        files: 12,
        teacher: "Cole Chandler",
        color: "bg-blue-400",
        avatars: ["CC", "AL", "MK"]
      },
      {
        title: "UNIT I",
        files: 16,
        teacher: "Cole Chandler",
        color: "bg-pink-400",
        avatars: ["CC", "JD", "SM"]
      }
    ]
  end

  def lessons_data
    [
      {
        class: "A1",
        teacher: "Bernard Carr",
        members: ["BC", "JD", "AL", "MK"],
        starting: "12.07.2022",
        material: "Download",
        payment: "Done",
        payment_color: "bg-blue-100 text-blue-800"
      },
      {
        class: "A1", 
        teacher: "Henry Poole",
        members: ["HP", "CC", "SM", "JK"],
        starting: "17.07.2022",
        material: "Download",
        payment: "Pending",
        payment_color: "bg-red-100 text-red-800"
      },
      {
        class: "A1",
        teacher: "Helena Lowe",
        members: ["HL", "MJ"],
        starting: "22.07.2022", 
        material: "Download",
        payment: "Done",
        payment_color: "bg-blue-100 text-blue-800"
      }
    ]
  end

  def reminders_data
    [
      {
        title: "Eng - Vocabulary test",
        date: "12 Dec 2022, Friday"
      },
      {
        title: "Eng - Essay",
        date: "12 Dec 2022, Friday"
      },
      {
        title: "Eng - Speaking Class",
        date: "12 Dec 2022, Friday"
      }
    ]
  end
end
