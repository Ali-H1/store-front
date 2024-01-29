<script setup lang="ts">
// @ts-nocheck
// import { reactive, ref, watch, computed } from 'vue'
import { computed, reactive, ref, watch } from "vue";
import { useStore } from "vuex";
import axios from "axios";
import config from "../config";
import { useRouter } from "vue-router"
// import Pagination from '../components/Pagination.vue';

const store = useStore();
const router = useRouter();
const userStatus = computed(() => {
  return store.state.userStatus;
});

type ProductState = {
  id: number;
  title: string;
  collections: string;
  price: number;
  image: Array;
  description: string;
};

const products = reactive([] as Array<ProductState>);
const productsAll = reactive([] as Array<ProductState>);

const cnt = ref(10)
const max_items = ref(10)
const loading = ref(true)

const currentPage = ref(1);

const sortPrice = ref("default")

const brandFilter = ref("")

// const updateCnt = () => {
//   cnt.value = cnt.value + 4;
// }
function get_data(page = 1, cat = "all", order = "") {
  let query = ""
  let page_q = ""
  loading.value = true;
  if (cat != "all") {
    cat = `collections_id=${cat}`
    query = "?"
  }
  else {
    cat = ""
  }
  if (order != "") {
    (order) ? order = `&ordering=${order}` : order = `ordering=${order}`;
    query = "?"
  }
  if (page != 1) {
    (query) ? page_q = `&page=${page}` : page_q = `page=${page}`;
    query = "?"
  }

  //products.splice(0, products.length);
  console.log(products, "1")
  axios
    .get("http://" + config.apiServer + ":" + config.port + "/store/products/" + query + cat + order + page_q)
    .then((res) => {
      // console.log(res.data.product_list);
      const productList = res.data.results;
      max_items.value = res.data.count
      console.log(res.data.count)
      productList.forEach((product: ProductState) => {
        axios
          .get("http://" + config.apiServer + ":" + config.port + "/store/collections/" + product.collections + "/")
          .then((cat) => {

            product.collections = cat.data.title
            console.log(cat.data.title, product.collections)
          }).then(() => {
            if (!product.images.length) {
              product.image = "https://secure.touchnet.net/C20965_ustores/web/images/product-default-image.png"
            }
            else {
              product.image = product.images[0].image;

            }

            // product.pic =
            //     "http://" + config.apiServer + ":" + config.port + "/api/img/" + product.pic;
            // product.thumbnail =
            //     "http://" +
            //     config.apiServer +
            //     ":" +
            //     config.port +
            //     "/api/img/" +
            //     product.thumbnail;
            products.push(product as ProductState);
            productsAll.push(product as ProductState);
          })
      });
      console.log(products.targ)
      loading.value = false
    })
    .catch((error) => {
      console.log(error);
      loading.value = false
    });
}
get_data();
const chgViewingProduct = (pid) => {
  store.commit("chgViewingProduct", pid);
};

chgViewingProduct("");

const search = () => {
  router.push("/search")
}

const initProduct = () => {
  if (products.length > 0) {
    while (products.length > 0) {
      products.pop()
    }
  }
}
const page_change = watch(currentPage, () => {
  get_data(currentPage.value, brandFilter.value, sortPrice.value)
})
const userName = computed(() => {
  return store.state.userName;
});

const products_brands = computed(() => {
  const categories = []
  axios
    .get("http://" + config.apiServer + ":" + config.port + "/store/collections/")
    .then((cat) => {
      cat.data.results.forEach((product) => {
        categories.push(product.title)
      })
    })
  return categories;
});

const filtered_products = computed(() => {

  if (sortPrice.value === 'price') {
    products.length = 0
    get_data(1, brandFilter.value, "price")
    return products;
  } else if (sortPrice.value === '-price') {
    products.length = 0
    get_data(1, brandFilter.value, "-price")
    return products;
  } else {
    products.length = 0
    get_data(1, brandFilter.value)
    return products;
  }
});

const maxPage = computed(() => {
  if (Math.ceil(max_items.value / cnt.value) === 0) {
    console.log(Math.ceil(max_items.value / cnt.value), "return 1")
    return 1
  } else {
    console.log(Math.ceil(max_items.value / cnt.value), "return actual size")
    return Math.ceil(max_items.value / cnt.value);
  }
});

const displayed_products = computed(() => {
  const start = (currentPage.value - 1) * cnt.value;
  const end = start + cnt.value;
  return filtered_products.value.slice(start, end);
});


const numEntryChgPage = () => {
  if (currentPage.value > maxPage.value) {
    currentPage.value = maxPage.value;
  } else if (currentPage.value < 1) {
    currentPage.value = 1;
  }
  chgPage()
}

const chgPage = () => {
  // console.log(displayed_products.value);

  if (typeof currentPage.value === "number") {
    if (currentPage.value > maxPage.value) {
      currentPage.value = maxPage.value;
    } else if (currentPage.value < 1) {
      currentPage.value = 1;
    }
  } else {
    currentPage.value = 1;
  }
  window.scrollTo(0, 0);
};

const prevPage = () => {
  currentPage.value = currentPage.value - 1;
  chgPage()
};

const nextPage = () => {
  currentPage.value = currentPage.value + 1;
  chgPage()
}

const initPage = () => {
  currentPage.value = 1;
  chgPage()
}

const selectBrand = (selBrand) => {
  brandFilter.value = selBrand
  initPage()
}

</script>

<template>
  <div class="flex items-center justify-center min-h-full px-4 py-6 sm:px-6 lg:px-8">
    <div class="w-full max-w-md space-y-8 lg:max-w-full lg:flex">
      <div class="sticky top-0 z-55 w-full max-w-md bg-slate-100 space-y-8 ml-3 mt-3">
        <h2 v-if="userStatus !== 'vendor'" class="text-2xl grid grid-cols-2 font-medium text-gray-900">
          <span class="col-span-1"><span class="font-bold ">Open</span>Mall</span>
          <span class="col-span-1 text-gray-500 text-[19px] text-right">Hi, {{ userName }}</span>
          <div class="text-sm col-span-2 text-gray-500">Online Shopping Mall Project for ISI</div>
        </h2>
        <div v-else class="">
          <router-link to="/manage">
            <div class="text-cyan-800">
              <div class="inline text-xl">&lsaquo;&nbsp;</div>
              <div class="inline text-md">Go Back</div>
            </div>
          </router-link>
          <h2 class="text-2xl grid grid-cols-2 font-medium text-gray-900">
            <span class="col-span-1"><span class="font-bold ">Modify</span> Products</span>
          </h2>
        </div>

        <div class="w-full max-w-md space-y-8 ">
          <div class="relative flex flex-wrap items-stretch w-full input-group backdrop-blur-sm rounded-2xl ">
            <input type="search"
              class="form-control relative flex-auto min-w-0 block w-full px-3 py-1.5 text-base font-normal text-gray-700 bg-slate-200 bg-clip-padding border-2 border-solid border-gray-100 rounded-lg transition ease-in-out m-0 focus:text-gray-700 focus:bg-white focus:border-indigo-600 focus:outline-none"
              placeholder="Search" aria-label="Search" aria-describedby="button-addon2" @click="search" autofocus />
            <div class="grid grid-cols-2 gap-3 w-full">
              <select @change="initPage()" v-model="brandFilter"
                class="lg:hidden col-span-1 bg-white rounded-lg w-full p-2 mt-4 mb-3 shadow-2xl">
                <option value="all">All Brands</option>
                <option v-for="brand in products_brands" :value="brand">{{ brand }}</option>
              </select>
              <select @change="initPage()" v-model="sortPrice"
                class="lg:col-span-2 col-span-1 bg-white rounded-lg w-full p-2 mt-4 mb-3 shadow-2xl">
                <option value="default">Sort default</option>
                <option value="price">Price (Low to High)</option>
                <option value="-price">Price (High to Low)</option>
                <option value="most">Mostly Viewed</option>
                <option value="feat">Featured</option>
              </select>
            </div>
            <div class="hidden lg:block grid grid-cols-2 gap-3 w-full">
              <button type="button" class="text-sm font-bold rounded-xl block p-2 col-span-1 m-1"
                @click="brandFilter = 'all'; initPage()">All</button>
              <div v-for="(selBrand, index) in products_brands">
                <button type="button" class="bg-gray-700 text-sm text-white rounded-xl block p-2 col-span-1 m-1"
                  v-if="selBrand === brandFilter" @click="selectBrand(index + 1)">{{ selBrand }}</button>
                <button type="button" class="text-sm hover:font-bold rounded-xl block p-2 col-span-1 m-1" v-else
                  @click="selectBrand(index + 1)">{{ selBrand }}</button>

              </div>
            </div>
          </div>
        </div>
      </div>
      <!--      <div class="grid grid-cols-1 gap-3 lg:grid-cols-3 lg:ml-8">-->
      <div v-if="displayed_products.length >= 3" class="ml-4" style="display: flex;flex-wrap: wrap;">
        <div v-for="product in displayed_products"
          class="break-inside-avoid hover:shadow-2xl max-w-md bg-white border rounded-lg grid-cols-1 shadow-sm mr-2 mb-2"
          style="max-width: 23%;" @click="
            $router.push('/product/' + product.id);
          chgViewingProduct(product.id);
          ">
          <!--          <div v-if="product.brand == brandFilter || brandFilter === 'all'">-->

          <img class="py-0 rounded-t-lg object-cover lg:h-80 lg:w-80" :src="product?.image" />
          <div class="px-5 py-2 pb-5">
            <h3 class="font-semibold tracking-tight text-gray-900 text-md">
              {{ product.title }}
            </h3>
            <h3 class="text-sm font-semibold tracking-tight text-gray-500">
              <!-- {{ product.pdesc.split(" ").slice(0, 8).join(" ") }} -->
              {{ product.description }}
            </h3>
            <div class="flex items-center mt-2.5 mb-5">
              <span class="bg-blue-100 text-blue-800 text-xs font-semibold mr-2 px-2.5 py-0.5 rounded">{{
                product.collections }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="font-bold text-gray-700 text-md">${{ product.price }}</span>
            </div>
          </div>
        </div>
        <div v-if="1" class="w-full lg:col-span-1 mt-7">
          <div class="bg-black p-2 bg-white rounded-lg text-white rounded-b-none shadow">
            Page {{ currentPage }}
            of {{ maxPage }}
          </div>
          <div class="p-2 bg-white rounded-lg shadow rounded-t-none">
            <div class="text-lg text-left">
              <input @blur="numEntryChgPage"
                class="h-6 rounded w-full text-center bg-slate-100 font-mono h-6 text-blue-500" v-model="currentPage"
                type="text"> <span class="p-2 "></span>
            </div>
            <div class="mt-2 grid grid-cols-2 gap-2">
              <button @click="prevPage"
                class="hover:bg-slate-100 hover:shadow-none border text-blue-500 h-14 rounded h-6 shadow">Previous</button>
              <button @click="nextPage"
                class="hover:bg-slate-100 hover:shadow-none border text-blue-500 h-14 rounded h-6 shadow">Next</button>
            </div>
          </div>

        </div>
      </div>
      <div v-else class="lg:grid lg:grid-cols-3 lg:gap-3 lg:ml-8 lg:h-full">
        <div v-for="product in displayed_products"
          class="break-inside-avoid hover:shadow-2xl max-w-md bg-white border w-full rounded-lg grid-cols-1 shadow-sm"
          @click="
            $router.push('/product/' + product.id);
          chgViewingProduct(product.id);
          ">
          <!--          <div v-if="product.brand == brandFilter || brandFilter === 'all'">-->

          <img class="py-0 rounded-t-lg object-cover lg:h-80 lg:w-80" :src="product.image" />
          <div class="px-5 py-2 pb-5">
            <h3 class="font-semibold tracking-tight text-gray-900 text-md">
              {{ product.title }}
            </h3>
            <h3 class="text-sm font-semibold tracking-tight text-gray-500">
              {{ product.description }}
            </h3>
            <div class="flex items-center mt-2.5 mb-5">
              <span class="bg-blue-100 text-blue-800 text-xs font-semibold mr-2 px-2.5 py-0.5 rounded">{{
                product.collections }}</span>
            </div>
            <div class="flex items-center justify-between">
              <span class="font-bold text-gray-700 text-md">${{ product.price }}</span>
            </div>
          </div>
          <div v-if="1" class="w-full mt-7 lg:col-span-1">
            <div class="bg-black p-2 bg-white rounded-lg text-white rounded-b-none shadow">
              Page {{ currentPage }}
              of {{ maxPage }}
            </div>
            <div class="p-2 bg-white rounded-lg shadow rounded-t-none">
              <div class="text-lg text-left">
                <input @blur="numEntryChgPage"
                  class="h-6 rounded w-full text-center bg-slate-100 font-mono h-6 text-blue-500" v-model="currentPage"
                  type="text"> <span class="p-2 "></span>
              </div>
              <div class="mt-2 grid grid-cols-2 gap-2">
                <button @click="prevPage"
                  class="hover:bg-slate-100 hover:shadow-none border text-blue-500 h-14 rounded h-6 shadow">Previous</button>
                <button @click="nextPage"
                  class="hover:bg-slate-100 hover:shadow-none border text-blue-500 h-14 rounded h-6 shadow">Next</button>
              </div>
            </div>

          </div>
        </div>
      </div>
      <div v-if="loading || products.length === 0" style="width: 100%;">
        <div class="wrap">
          <div v-if="loading" class="spinner"></div>
          <h2 v-else="products.length === 0 "> Nothing Found :( </h2>


        </div>
      </div>
      <!--      <div class="text-blue-500 text-center" @click="updateCnt">More</div>-->

    </div>
  </div>
</template>
<style scoped>
.wrap {
  /*   Flex Perfect Centring  */
  display: flex;
  justify-content: center;
  align-items: center;
  height: 90vh;
}


/* SPINER */

.spinner {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  border: 4px solid #F00;
  border-left: 4px solid #e3e4e7;
  animation: spinner 1.5s linear infinite;
  margin: 100px;
}


@keyframes spinner {
  0% {
    transform: rotate(0deg);
  }

  100% {
    transform: rotate(360deg);
  }
}
</style>
