# 1. Get SHA256 for latest release tag                                                                                            
  `curl -sL https://github.com/cactus-compute/cactus/archive/refs/tags/v0.1.0.tar.gz | shasum -a 256`            
                                                                                                               
  # 2. Update the formula with real SHA256                                                                     
                                                                                                               
  # 3. Push the tap repo                                                              
  `git add .`                                                                                                    
  `git commit -m "Add cactus formula"`                                                                           
  `git push origin main`                                                                                         
                                        