class Comment < Post
  #treat users and authors as synonymous for comments
  alias_attribute :author, :user
  
  ## Upon creation, trigger the check to see whether this needs to be emailed (Events don't get that check)
end