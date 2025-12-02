import os
from instagrapi import Client as InstaClient
import tweepy
from pathlib import Path

class SocialMediaPoster:
    def __init__(self):
        # Instagram credentials
        self.insta_username = os.getenv('INSTAGRAM_USERNAME')
        self.insta_password = os.getenv('INSTAGRAM_PASSWORD')
        
        # X (Twitter) API credentials
        self.x_api_key = os.getenv('X_API_KEY')
        self.x_api_secret = os.getenv('X_API_SECRET')
        self.x_access_token = os.getenv('X_ACCESS_TOKEN')
        self.x_access_secret = os.getenv('X_ACCESS_SECRET')
        
        # Initialize clients
        self.insta_client = None
        self.x_client = None
    
    def setup_instagram(self):
        """Authenticate with Instagram"""
        try:
            self.insta_client = InstaClient()
            self.insta_client.login(self.insta_username, self.insta_password)
            print("✓ Instagram authentication successful")
            return True
        except Exception as e:
            print(f"✗ Instagram authentication failed: {e}")
            return False
    
    def setup_x(self):
        """Authenticate with X (Twitter)"""
        try:
            client = tweepy.Client(
                consumer_key=self.x_api_key,
                consumer_secret=self.x_api_secret,
                access_token=self.x_access_token,
                access_token_secret=self.x_access_secret
            )
            
            # API v1.1 for media upload
            auth = tweepy.OAuth1UserHandler(
                self.x_api_key,
                self.x_api_secret,
                self.x_access_token,
                self.x_access_secret
            )
            api = tweepy.API(auth)
            
            self.x_client = {'client': client, 'api': api}
            print("✓ X authentication successful")
            return True
        except Exception as e:
            print(f"✗ X authentication failed: {e}")
            return False
    
    def post_to_instagram(self, image_path, caption):
        """Post image to Instagram"""
        try:
            if not self.insta_client:
                print("Instagram client not initialized")
                return False
            
            path = Path(image_path)
            if not path.exists():
                print(f"Image file not found: {image_path}")
                return False
            
            # Upload photo
            media = self.insta_client.photo_upload(
                path=str(path),
                caption=caption
            )
            print(f"✓ Posted to Instagram (Media ID: {media.pk})")
            return True
        except Exception as e:
            print(f"✗ Instagram post failed: {e}")
            return False
    
    def post_to_x(self, image_path, caption):
        """Post image to X (Twitter)"""
        try:
            if not self.x_client:
                print("X client not initialized")
                return False
            
            path = Path(image_path)
            if not path.exists():
                print(f"Image file not found: {image_path}")
                return False
            
            # Upload media
            media = self.x_client['api'].media_upload(filename=str(path))
            
            # Create tweet with media
            tweet = self.x_client['client'].create_tweet(
                text=caption,
                media_ids=[media.media_id]
            )
            print(f"✓ Posted to X (Tweet ID: {tweet.data['id']})")
            return True
        except Exception as e:
            print(f"✗ X post failed: {e}")
            return False
    
    def post_to_both(self, image_path, caption):
        """Post to both Instagram and X simultaneously"""
        print(f"\nPosting to social media...")
        print(f"Image: {image_path}")
        print(f"Caption: {caption[:50]}{'...' if len(caption) > 50 else ''}\n")
        
        # Setup clients
        insta_ready = self.setup_instagram()
        x_ready = self.setup_x()
        
        if not insta_ready and not x_ready:
            print("\n✗ Both platforms failed to authenticate")
            return False
        
        # Post to both platforms
        insta_success = self.post_to_instagram(image_path, caption) if insta_ready else False
        x_success = self.post_to_x(image_path, caption) if x_ready else False
        
        # Summary
        print("\n" + "="*50)
        if insta_success and x_success:
            print("✓ Successfully posted to both platforms!")
        elif insta_success or x_success:
            print("⚠ Partially successful - check messages above")
        else:
            print("✗ Failed to post to any platform")
        print("="*50)
        
        return insta_success or x_success


def main():
    """Example usage"""
    poster = SocialMediaPoster()
    
    # Example post
    image_path = "path/to/your/image.jpg"
    caption = "Your caption here! #hashtag"
    
    poster.post_to_both(image_path, caption)


if __name__ == "__main__":
    main()