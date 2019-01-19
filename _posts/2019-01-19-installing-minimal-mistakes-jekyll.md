---
layout: single
title:  "Setting up jekyll with minimal-mistakes theme"
date:   2019-01-19 08:22:36 +1100
categories: jekyll theme
---
Ok so we want to make a new jekyll blog. Cool! First things first, have `jekyll` installed in a local scope and add `gems` to your `PATH` in `~/.bashrc` etc etc. 

I am assuming you have an environment set up, let's go!

```bash
jekyll new obrasier.github.io
```
```bash
owen@owen-linux:~/repos/obrasier.github.io -> ls
404.html  about.md  _config.yml  Gemfile  Gemfile.lock  index.md  _posts
```
I have a couple of goals, which I think *should* be simple:

- install the minimal mistakes theme
- host on Github Pages
- be able to build it locally

Ok, now we have the enviroment setup, let's install the `minimal-mistakes` theme... oh, there's 3 ways to install it. 

I like the _idea_ of installing it remotely, let's do that.

So let's replace `Gemfile` to contain

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
```
Add `jekyll-include-cache` to `plugins` in `_config.yml`:

```yaml
plugins:
  - jekyll-feed
  - jekyll-include-cache
```

Ok, let's build the site and see if it works!

```bash
bundle exec jekyll serve
```

Uh oh!
```bash
Configuration file: /home/owen/repos/test/_config.yml
  Dependency Error: Yikes! It looks like you don't have jekyll-include-cache or one of its dependencies installed. In order to use Jekyll as currently configured, you'll need to install this gem. The full error message from Ruby is: 'cannot load such file -- jekyll-include-cache' If you run into trouble, you can find helpful resources at https://jekyllrb.com/help/!
jekyll 3.7.4 | Error:  jekyll-include-cache
```
So the required package is in my plugins, is the problem that it's not installed locally? Let's add it to the `Gemfile`

```ruby
gem "jekyll-include-cache"
```
...run `bundle` again, and then `bundle exec jekyll serve`

This looks promising...
```bash
Configuration file: /home/owen/repos/obrasier.github.io/_config.yml
            Source: /home/owen/repos/obrasier.github.io
       Destination: /home/owen/repos/obrasier.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
      Remote Theme: Using theme mmistakes/minimal-mistakes
...
```
It takes a while, because it's a remote theme, which for a local build might be slightly annoying. I'm sure it'll download those files locally and compare the git tags, right?

Oh no... another error:
```bash
Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
  Liquid Exception: No repo name found. Specify using PAGES_REPO_NWO environment variables, 'repository' in your configuration, or set up an 'origin' git remote pointing to your github.com repository. in /_layouts/default.html
             ERROR: YOUR SITE COULD NOT BE BUILT:
                    ------------------------------------
                    No repo name found. Specify using PAGES_REPO_NWO environment variables, 'repository' in your configuration, or set up an 'origin' git remote pointing to your github.com repository.
```
I need to set an environment variable? Hmmmm.... am I doing this right? I mean, why would I even want to build my site locally?

I'll keep shaving this yak for a bit longer... 

Let's add a `repository` to `_config.yml`

```yaml
repository: obrasier/obrasier.github.io
```

Ok, lets' see if this works now. According to [this github issue ticket](https://github.com/jekyll/jekyll/issues/4705), I should be able to build locally by removing `gh-pages`, however, I _do_ want to host on Github Pages, so I want this step to work anyway.

Woo!

```bash
Configuration file: /home/owen/repos/obrasier.github.io/_config.yml
            Source: /home/owen/repos/obrasier.github.io
       Destination: /home/owen/repos/obrasier.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
      Remote Theme: Using theme mmistakes/minimal-mistakes
       Jekyll Feed: Generating feed for posts
   GitHub Metadata: No GitHub API authentication could be found. Some fields may be missing or have incorrect data.
     Build Warning: Layout 'post' requested in _posts/2019-01-19-welcome-to-jekyll.markdown does not exist.
     Build Warning: Layout 'page' requested in about.md does not exist.
                    done in 263.116 seconds.
 Auto-regeneration: enabled for '/home/owen/repos/obrasier.github.io'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

But my posts aren't showing... grrrrrrrr... seriously? Am I doing something dumb? Why can't stuff just work? Plus, the remote theme takes *ages* to build each time. I don't think this is going to work. How about I abandon the `remote_theme` idea and use a local one instead.

So update `_config.yml`
```yaml
theme: minimal-mistakes-jekyll
```
and add to the `Gemfile`
```ruby
gem "minimal-mistakes-jekyll"
```

Ok! That builds super fast! I'm at the same point with the Remote themes. On the site... I just get a heading "Recent Posts" ... but without any posts displaying.

It looks like this:

![screenshot](/assets/images/pagination.png)

Hmmmmmmm..... Let's continue! In the [Setup your site](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/#setup-your-site) section, it says to replace the `index.md` with this contents, and to call it `index.html`, ok!

```yaml
---
layout: home
author_profile: true
---
```

We also need to add the `pagination` settings because it's of layout `home` to `_config.yml`
```yaml
paginate: 5 # amount of posts to show
paginate_path: /page:num/
```
Is the post showing?

![screenshot](/assets/images/pagination.png)

... I guess not. Let's continue.

So that takes us to the end of the "Quick-start guide" ... shit isn't working. What do?

Ok, first things first, let's backup `_config.yml` and steal the one from [the repo](https://github.com/mmistakes/minimal-mistakes/blob/master/_config.yml). It has lots of settings, maybe we can get it working from a site that is working, and see if we can isolate the setting.

Make sure to uncomment the `theme: ` line

```yaml
theme                    : "minimal-mistakes-jekyll"
```

Boo ya! That works and displays all the things. Ok, settings must be the problem then. But which one was it? Do I even care? 

To be honest, not really.

What is a setting that looks like it could be a thing that loads a site sensibly? That _wasn't_ there by default.

Maybe it was a plugin thing? Swapping the plugins back actually made the posts load, and the sidebar on the left still didn't load. I am sure I'll learn more about these settings as I continue to use Jekyll. Anyway, try a verified configuration, even if you use `jekyll new` like I did. I think there's something missing in their guide, but I got it working now. Now to change the theme and add some personal configurations.

Changing to the `dark` theme, adding an avatar. I think my next post might be on editing the title colours in the theme, it's a bit... white.

But that's a post for another day. 

Ok, let's push and see if it displays on github:

![*... blank white page ...*](/assets/images/white.png)

Nooooooooooooooooooooo!

Ok, there's some configuration that I haven't added. According [to this](https://stackoverflow.com/questions/49071139/jekyll-github-works-on-local-but-empty-page-on-https-username-github-io) you need to use the `remote_theme` feature. LOL. Back to square one.

So make the `_config.yml` like this.
```yaml
# theme                    : "minimal-mistakes-jekyll"
remote_theme             : "mmistakes/minimal-mistakes"
```

...and it works! Yay!

It takes exactly... a long time for it to pull down the remote theme on my local computer, but whatevs, it still builds. 🤷‍♂️

```
done in 303.062 seconds.
```
🤦‍♂️

Looking at the Quick-start guide it says "Remote themes are similar to Gem-based themes, but do not require Gemfile changes or whitelisting making them ideal for sites hosted with GitHub Pages."

... and it doesn't say...

"in order to host on Github Pages you **must** use a `remote_theme` or fork the repo." Although to be fair it's not up to the theme to tell everyone how Github works. Just for a n00b like me, it would have been helpful. That's all.

Cool! So that works, now I can write stuff that noone can read, yay! I'll look into customising the theme soon, which I imagine involves making local versions of the theme files, and yay CSS, my favourite thing! 

Plus, that build time makes me want to punch people. So it might be that I'll have to fork the theme repo and host it all locally. I guess that works, it won't do the versioning thingy-thing, but do I really care?

I care about not wanting to punch stuff, so I might just do that. Plus, I'll want to edit some stuff anyway, so this remote stuff is a kind of nice idea, but also actually just annoying. 

The internet is not that good just yet that we can treat everything is on a LAN, not in Australia anyway.

So what's a nerd gonna do? It's obvious right, let's fork the `minimal-mistakes` repo, run all the files locally, and not set a theme at all!

... *insert long waiting period here for the files to download* ...

... and it works! Pushes to Github pages, it's up, it's toally sweet. Let's try and build it locally, this is why we forked it after all:

```bash
$ bundle exec jekyll serve
Could not find gem 'rake (~> 10.0)' in any of the gem sources listed in your Gemfile.
Run `bundle install` to install missing gems.
```
Uh oh....

ok, let's run `bundle`

```bash
Fetching gem metadata from https://rubygems.org/..........
Fetching gem metadata from https://rubygems.org/.
Resolving dependencies...
Bundler could not find compatible versions for gem "bundler":
  In Gemfile:
    bundler (~> 1.15)

  Current Bundler version:
    bundler (2.0.1)
This Gemfile requires a different version of Bundler.
Perhaps you need to update Bundler by running `gem install bundler`?

Could not find gem 'bundler (~> 1.15)' in any of the relevant sources:
  the local ruby installation
```

...wat? 

You want a bundler version that's old? Srsly? 🤦‍♂️

Ok maybe it's just me, probs not meant to fork it and expect it to "just work", it builds on Github Pages fine, but my local stuff isn't installed.

Let's look at the `Gemfile`
```ruby
source "https://rubygems.org"
gemspec
```
Hmmm, what is a `gemspec`? There's a file: `minimal-mistakes-jekyll.gemspec`, interesting...

```
  spec.add_development_dependency "bundler", "~> 1.15"
```
what happens if I delete the version?
```
  spec.add_development_dependency "bundler"
```

... it works! YAY! And builds in 2 seconds, OMG technology!

So that works, but *really*!? I have to maintain a fork just to get my site to build quickly?

There must be a better way, and there is. We can pass in a local configuration file

```bash
bundle exec jekyll serve --config CONFIG_FILE
```

This lets us pass in a separate config for a remote and local build. Let's write a quick and dirty hack using `sed` to generate a local version for us.

```bash
#!/bin/bash
cp _config.yml _local_development.yml

# delete the line with remote_theme setting
sed -i '/remote_theme/d' _local_development.yml

# change the commented line to have the theme setting
sed -i '/minimal-mistakes-jekyll"/c\theme                    : "minimal-mistakes-jekyll"' _local_development.yml

# run the server
bundle exec jekyll serve --config _local_development.yml
```
Yes I know it is a bit of a cheap hack and I'll have to be careful not to use the full theme name blah blah blah, it works. You can deal.

So why did this happen in the first place? Why are there 3 different installation options that I need to learn/understand just in order to install a theme on a blog?

I think the problem here is *flexibility*. I mean, it's not a bad thing, I use linux and have some fundamental ethos about being able to tinker with all the things.

But, the quick start guide wasn't written poorly, the ability to host things in different places is a nice thing, getting a remote theme is a nice *idea*. 

But... it doesn't work. 

My internet is too shit to use a remote theme, Github Pages can't use the gemfile method for reasons, so either I host somewhere else (I considered it), so I just fork the theme which specifies a version for a build and have to randomly change a value in order for it to work the way I want.

Conclusion: everything is broken and everything is hard. I don't know how to fix, but t1his is just one tiny example it just not working for no reason.

It's okay though, the whole world is like that. It's not just us.