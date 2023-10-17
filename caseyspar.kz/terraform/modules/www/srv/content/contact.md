---
title: 'Contact'
date: '2021-10-03T13:10:36.000Z'
draft: false
language: 'en'
description: 'Contact Page'

---

<!-- @format -->
<section class="lg:pb-24">
    <div class="max-w-screen-md px-4 mx-auto">
        <p class="
            mb-8
            font-light
            text-center
            text-gray-500
            lg:mb-16
            dark:text-gray-400
            sm:text-xl"
        >Want to reach out? Do it here.</p>
        <form
            name="contact"
            class="space-y-8"
            action="https://2zwdyvd7gc.execute-api.us-west-2.amazonaws.com/contact_form"
            method="POST"
            >
            <!-- Sender name --><div class="my-4">
                <label
                    for="email"
                    class="
                        block
                        mb-2
                        font-medium
                        text-gray-900
                        text-md
                        dark:text-gray-300
                    "
                ><strong>From</strong></label>
                <input
                    type="text"
                    id="sender_name"
                    placeholder="Your Name"
                    name="sender_name"
                    class="
                        shadow-sm
                        bg-gray-50
                        border
                        border-gray-300
                        text-gray-900
                        text-md
                        rounded-lg
                        focus:ring-indigo-500
                        focus:border-indigo-500
                        block
                        w-full
                        p-2.5
                        dark:bg-gray-700
                        dark:border-gray-600
                        dark:placeholder-gray-400
                        dark:text-white
                        dark:focus:ring-indigo-500
                        dark:focus:border-indigo-500
                        dark:shadow-sm-light
                    "
                    required
                >
            </div>
            <!-- Sender email address --><div class="my-4">
                <input
                    type="email"
                    id="sender_email"
                    name="sender_email"
                    class="
                        shadow-sm
                        bg-gray-50
                        border
                        border-gray-300
                        text-gray-900
                        text-md
                        rounded-lg
                        focus:ring-indigo-500
                        focus:border-indigo-500
                        block
                        w-full
                        p-2.5
                        dark:bg-gray-700
                        dark:border-gray-600
                        dark:placeholder-gray-400
                        dark:text-white
                        dark:focus:ring-indigo-500
                        dark:focus:border-indigo-500
                        dark:shadow-sm-light
                    "
                    placeholder="your_email@example.com"
                    required
                >
            </div>
            <!-- Email subject --><div class="my-4">
                <label
                    for="subject"
                    class="
                        block
                        mb-2
                        font-medium
                        text-gray-900
                        text-md
                        dark:text-gray-300
                    "
                ><strong>Subject</strong></label>
                <input
                    type="text"
                    id="subject"
                    name="subject"
                    class="
                        block
                        w-full
                        p-3
                        text-gray-900
                        border
                        border-gray-300
                        rounded-lg
                        shadow-sm
                        text-md
                        bg-gray-50
                        focus:ring-indigo-500
                        focus:border-indigo-500
                        dark:bg-gray-700
                        dark:border-gray-600
                        dark:placeholder-gray-400
                        dark:text-white
                        dark:focus:ring-indigo-500
                        dark:focus:border-indigo-500
                        dark:shadow-sm-light
                    "
                    required
                >
            </div>
            <!-- Email body --><div class="my-4 sm:col-span-2">
                <label for="message" class="block mb-2 font-medium text-gray-900 text-md dark:text-gray-400"><strong>Body</strong></label>
                <textarea
                    id="message"
                    name="message"
                    rows="6"
                    class="
                        block
                        p-2.5
                        w-full
                        text-md
                        text-gray-900
                        bg-gray-50
                        rounded-lg
                        shadow-sm
                        border
                        border-gray-300
                        focus:ring-indigo-500
                        focus:border-indigo-500
                        dark:bg-gray-700
                        dark:border-gray-600
                        dark:placeholder-gray-400
                        dark:text-white
                        dark:focus:ring-indigo-500
                        dark:focus:border-indigo-500
                    "
                ></textarea>
            </div>
            <!-- Submit button --><div class="mt-6 lg:pb-16">
                <button
                    type="submit"
                    class="
                        px-5
                        py-3
                        font-bold
                        text-center
                        text-white
                        bg-indigo-600
                        rounded-lg
                        text-md
                        sm:w-fit
                        hover:bg-indigo-800
                        focus:ring-4
                        focus:outline-none
                        focus:ring-indigo-300
                        dark:bg-indigo-600
                        dark:hover:bg-indigo-700
                        dark:focus:ring-indigo-800
                    "
                >Send</button>
            </div>
        </form>
    </div>
</section>
