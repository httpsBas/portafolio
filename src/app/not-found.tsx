import NyanCat from "@/components/nyan-cat";
import { cn } from "@/lib/utils";
import { withBasePath } from "@/lib/base-path";
import Spline from "@splinetool/react-spline";
import { Application } from "@splinetool/runtime";
import React, { Suspense } from "react";

const NotFoundPage = () => {
  return (
    <>
      <Suspense fallback={<div>Loading...</div>}>
        <Spline scene={withBasePath("/assets/404.spline")} style={{ height: "100vh" }} />
      </Suspense>
    </>
  );
};

export default NotFoundPage;
