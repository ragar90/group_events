require 'rails_helper'


RSpec.describe "/events", type: :request do
  let(:params) {
    {
      group_event:{
        start_date: Time.now,
        duration: 3,
        name: "Cool Event",
        description: "Event for cool people",
        location: "Cool Beach House"
      }
    }
  }

  let(:path){ events_path}


  describe "GET /index" do
    it "renders a successful response" do
      create_list(:valid_group_event, 5)
      create_list(:valid_group_event, 5, :deleted)
      get path, as: :json
      expect(response).to have_http_status(:success)
      expect(response).to list_group_events(GroupEvent.not_deleted)
    end
  end

  describe "GET /show" do
    let(:deleted_event){ create(:valid_group_event, :deleted) }
    let(:event){ create(:valid_group_event) }
    let(:path){ event_path(id: event.id) }
    it "renders a successful response" do
      get path, as: :json
      expect(response).to have_http_status(:success)
      body = JSON.parse(response.body)
      expect(body).to describe_group_event(event)
    end

    it "should return 404 for deleted events" do
      path = event_path(id: deleted_event.id)
      get path, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Event" do
        expect {
          post path, params: params, as: :json
          expect(response).to have_http_status(:created)
        }.to change(GroupEvent.not_deleted, :count).by(1)
      end

      it "renders a JSON response with the new event" do
        post path, params: params, as: :json
        expect(response).to have_http_status(:created)
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body).to describe_group_event(GroupEvent.not_deleted.order("created_at desc").first)
      end
    end

    context "with invalid parameters" do
      let(:params) {
        {
          group_event:{
            start_date: Time.now,
            name: "Cool Event",
            description: "Event for cool people",
            location: "Cool Beach House"
          }
        }
      }

      it "does not create a new Event" do
        expect {
          post path, params: params, as: :json
        }.to change(GroupEvent.not_deleted, :count).by(0)
      end

      it "renders a JSON response with errors for the new event" do
        post path, params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    let(:event){ create(:valid_group_event) }
    let(:path){ event_path(id: event.id) }
    context "with valid parameters"  do
      let(:params) {
        {
          group_event:{
            name: "Another Cool Event",
            description: "Another Event for cool people",
            location: "Another Cool Beach House"
          }
        }
      }

      it "updates the requested event" do
        patch path, params: params, as: :json
        event.reload
        expect(response).to have_http_status(:success)
        body = JSON.parse(response.body)
        expect(body).to describe_group_event(event)
      end
    end

    context "with invalid parameters" do
      let(:params) {
        {
          group_event:{
            start_date: Time.now,
            duration: 3,
            end_date: Time.now + 10.days
          }
        }
      }
      it "renders a JSON response with errors for the event" do
        patch path, params: params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    let(:events){create_list(:valid_group_event, 5)}
    let(:path){event_path(id: events.first.id)}
    it "destroys the requested event" do
      expect {
        delete path, as: :json
      }.to change(GroupEvent.deleted, :count).by(1)
    end
  end
end
