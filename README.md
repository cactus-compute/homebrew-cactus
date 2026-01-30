# 1. Create a release tag                                                                                    
  `cd /Users/henryndubuaku/Desktop/cactus`                                                                 
  `git tag v0.1.0`                                                                                               
  `git push origin v0.1.0`                                                                                       
                                                                                                               
  # 2. Get SHA256                                                                                              
  `curl -sL https://github.com/cactus-compute/cactus/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256`            
                                                                                                               
  # 3. Update the formula with real SHA256                                                                     
                                                                                                               
  # 4. Push the tap repo                                                                                       
  `cd /Users/henryndubuaku/Desktop/homebrew-cactus`                                                              
  `git add .`                                                                                                    
  `git commit -m "Add cactus formula"`                                                                           
  `git push origin main`                                                                                         
                                        