# 22

> A simple and lightweight alternative to Calibre.

## Update

As of now, I am halting development of 22. There are many different reasons why I've decided to throw in the towel. I have learned that ebook managers are *much* more difficult to get right than I had previosuly imagined. To support the wide array of formats and the many different intracacies of each would require more effort than I am willing to put forth at this time.

The most difficult aspect of the project is in regards to conversion and metadata editing. I have found Vala to be extremely lacking in terms of its libxml-2.0 library and it was painful trying to edit the ebook metadata using it. There is little documentation and a very small userbase for the library. I also have grown tired of Vala as a language. Similar to libxml-2.0 it has a small user-base and very little community support. I would prefer to spend my time in a language that I see has a more promising future and more relevance to my career. 

I have also stopped using Elementary OS and I no longer wished to publish it only to the AppCenter. I currently use Manjaro XFCE with i3-gaps and I don't want to fiddle around making it look good on Elementary. The reasons for my switch include outdated software in the repositories, various bugs with the operating system that I have little hope will ever be fixed, and other small things.

Lastly, through the course of development I have learned what a tremendous application Calibre is. It is able to handle any format you throw at it and is a one-stop-shop for all ebook needs. I have been using it for years and if my only complaint is that it has a bunch of functionality that I don't use, then I am willing to keep using it. To develop a minimal version would require a rewrite of all of the existing and well-tested ebook conversion and editing code that already works perfectly with Calibre.

I learned a lot and had some fun attempting to develop such an application. I will always develop applications that I find personally useful and if something changes in the future, I am not against trying again.

- Evan

## Screenshots

### Library View
![library view](https://raw.githubusercontent.com/evan-buss/22/master/screenshots/library_view.png)

### Setup View
![setup view](https://raw.githubusercontent.com/evan-buss/22/master/screenshots/setup.png)

### Search View
![search view](https://raw.githubusercontent.com/evan-buss/22/master/screenshots/search_view.png)

### Metadata Editor
![metadata editor](https://raw.githubusercontent.com/evan-buss/22/master/screenshots/metadata_editor.png)


## Why?

Calibre is overkill for the majority of my ebook management needs. All I really need is a way to edit the book's metadata, convert the book to kindle format if necessary, and manage books that are installed on my devices. I don't need any sort of "server" or ebook viewing / editing capabilities. Calibre has grown into a behemoth of an an application; the goal of 22 is to provide similar features with a much lighter application.

## Goals

The library will follow the same folder and file structure as Calibre so you should
be able to use either application interchangably and with your existing Calibre library.

### Proposed Features
- [ ] View your ebook library
- [ ] Manage ebook metadata
- [ ] Convert epub to mobi (Support kindles)
  - Need to find a conversion library or write my own...
- [ ] Send books to e-readers
