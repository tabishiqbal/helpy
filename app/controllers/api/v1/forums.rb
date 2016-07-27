require 'doorkeeper/grape/helpers'

module API
  module V1
    class Forums < Grape::API
      helpers Doorkeeper::Grape::Helpers
      #
      # before do
      #   doorkeeper_authorize!
      # end
      before do
        authenticate!
        restrict_to_role %w(admin agent)
      end

      include API::V1::Defaults
      resource :forums do

        throttle max: 200, per: 1.minute

        # LIST ALL FORUMS
        desc "List all forums", {
          entity: Entity::Forum,
          notes: "List all Forums"
        }
        get "", root: :forums do
          forums = Forum.all
          present forums, with: Entity::Forum
        end

        # SHOW ONE FORUM
        desc "Show one forum", {
          entity: Entity::Forum,
          notes: "Returns details of one forum, including topics"
        }
        params do
          requires :id, type: String, desc: "ID of the forum"
          optional :topics_limit, type: Integer, desc: "How many topics to return"
        end
        get ":id", root: "forum" do
          forum = Forum.where(id: permitted_params[:id]).first!
          present forum, with: Entity::Forum, topics: true
        end

        # CREATE NEW FORUM
        desc "Create a new forum", {
          entity: Entity::Forum,
          notes: "Create a new forum"
        }
        params do
          requires :name, type: String, desc: "The name of the forum"
          requires :allow_post_voting, type: Boolean, desc: "Should topic replies be voteable?"
          requires :allow_topic_voting, type: Boolean, desc: "Should topics be voteable?"
          requires :layout, type: String, desc: "The author of the article"
        end
        post "", root: :forums do
          forum = Forum.create!(
            name: permitted_params[:name],
            allow_topic_voting: permitted_params[:allow_topic_voting],
            allow_post_voting: permitted_params[:allow_post_voting],
            layout: permitted_params[:layout]
          )
          present forum, with: Entity::Forum
        end

        # UPDATE EXISTING FORUM
        desc "Update a forum", {
          entity: Entity::Forum,
          notes: "Update a forum"
        }
        params do
          requires :id, type: Integer, desc: "The ID of the forum you are updating"
          requires :name, type: String, desc: "The name of the forum"
          requires :allow_post_voting, type: Boolean, desc: "Should topic replies be voteable?"
          requires :allow_topic_voting, type: Boolean, desc: "Should topics be voteable?"
          requires :layout, type: String, desc: "The author of the article"
        end
        patch ":id", root: :forums do
          forum = Forum.where(id: permitted_params[:id])
          forum.update!(
            name: permitted_params[:name],
            allow_topic_voting: permitted_params[:allow_topic_voting],
            allow_post_voting: permitted_params[:allow_post_voting],
            layout: permitted_params[:layout]
          )
          present forum, with: Entity::Forum
        end
      end
    end
  end
end