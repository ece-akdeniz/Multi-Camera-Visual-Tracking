from setuptools import find_packages, setup

package_name = "befr_visual_tracking"

setup(
    name=package_name,
    version="0.1.0",
    packages=find_packages(exclude=["tests"]),
    data_files=[
        ("share/ament_index/resource_index/packages", [f"resource/{package_name}"]),
        (f"share/{package_name}", ["package.xml"]),
        (f"share/{package_name}/config", ["config/cameras.yaml"]),
    ],
    install_requires=[
        "numpy>=1.24",
        "PyYAML>=6.0",
    ],
    zip_safe=True,
    maintainer="BEFR Team",
    maintainer_email="team@example.com",
    description="Multi-camera Bayesian visual tracking for quadcopter state estimation",
    license="MIT",
    tests_require=["pytest"],
    entry_points={
        "console_scripts": [],
    },
)
