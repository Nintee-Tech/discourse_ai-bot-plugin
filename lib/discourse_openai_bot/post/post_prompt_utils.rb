module ::DiscourseOpenAIBot

  class PostPromptUtils < PromptUtils

    def self.create_prompt(opts)
      post_collection = collect_past_interactions(opts[:reply_to_message_or_post_id])
      # {p.user.username}
       content = post_collection.reverse.map { |p| <<~MD }
       #{p.raw}
       ---
       MD
       return content
    end


    def self.collect_past_interactions(message_or_post_id)
      current_post = Post.find(message_or_post_id)

      post_collection = []

      post_collection << current_post

      collect_amount = SiteSetting.openai_bot_max_look_behind

      while post_collection.length < collect_amount do
        if current_post.reply_to_post_number
          #current_post = Post.find_by(topic_id: current_post.topic_id, post_number: current_post.reply_to_post_number)
          current_post = Post.find(current_post.reply_to_post_number)
        else
          if current_post.post_number > 1
            current_post = Post.where(topic_id: current_post.topic_id, deleted_at: nil).where('post_number < ?', current_post.post_number).last
          else
            break
          end
        end

        post_collection << current_post
      end

      post_collection
    end
  end
end